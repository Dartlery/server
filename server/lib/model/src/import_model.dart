import 'dart:async';
import 'dart:io';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/extensions/extensions.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery/tools.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:sqljocky/sqljocky.dart';

import 'a_model.dart';
import 'item_model.dart';
import 'tag_category_model.dart';

class ImportModel extends AModel {
  static final Logger _log = new Logger('ImportModel');

  final ItemModel itemModel;
  final TagCategoryModel tagCategoryModel;
  final AImportResultsDataSource _importResultsDataSource;
  final ABackgroundQueueDataSource _backgroundQueueDataSource;

  final RegExp shimmieFileRegexp = new RegExp(r"^\d+ \- (.+)$");

  final RegExp tagSplitterRegExp = new RegExp(r'[\""].+?[\""]|[^ ]+');

  ImportModel(
      this.itemModel,
      this.tagCategoryModel,
      this._importResultsDataSource,
      this._backgroundQueueDataSource,
      AUserDataSource userDataSource)
      : super(userDataSource);

  @override
  Logger get loggerImpl => _log;

  Future<Null> clearResults([bool everything = false]) async {
    await validateDeletePrivileges();
    await _importResultsDataSource.clear(everything);
  }

  Future<DateTime> enqueueImportFromPath(String path,
      {bool interpretShimmieNames: false, bool stopOnError: false, bool mergeExisting: false}) async {
    await validateUpdatePrivilegeRequirement();

    if(isNullOrWhitespace(path)) {
      throw new ArgumentError.notNull("path");
    }
    final Directory dir = new Directory(path);
    if(!dir.existsSync()) {
      throw new ArgumentError("path not found");
    }

    final DateTime batchTimestamp = new DateTime.now();
    final Map<String, dynamic> data = <String, dynamic>{};
    data["path"] = path;
    data["interpretShimmieNames"] = interpretShimmieNames;
    data["stopOnError"] = stopOnError;
    data["batchTimestamp"] = batchTimestamp;
    data["mergeExisting"] = mergeExisting;
    await _backgroundQueueDataSource
        .addToQueue(ImportPathExtension.pluginIdStatic, data, priority: 10);
    return batchTimestamp;
  }

  Future<PaginatedData<ImportResult>> getResults(
      {int page: 0, int perPage: defaultPerPage}) async {
    await validateGetPrivileges();
    return await _importResultsDataSource.get(page: page, perPage: perPage);
  }

  Future<Null> importFromPath(String path,
      {bool interpretShimmieNames: false,
      bool stopOnError: false,
      DateTime overrideBatchTimestamp,
      mergeExisting: false}) async {
    final TagList tagList = new TagList();
    final DateTime batchTimestamp =
        overrideBatchTimestamp ?? new DateTime.now();

    await _importFromFolderRecursive(batchTimestamp, new Directory(path),
        tagList, interpretShimmieNames, stopOnError, mergeExisting);
  }

  Future<Null> importFromShimmie(String imagePath, String mysqlHost, String mysqlUser, String mysqlPassword, String mysqlDb,
      {int startAt: -1, bool stopOnError: false, bool interpretTagCategories: true, bool mergeExisting: true}) async {
    final ConnectionPool pool = new ConnectionPool(
        host: mysqlHost,
        user: mysqlUser,
        password: mysqlPassword,
        db: mysqlDb);

    final DateTime batchTimestamp = new DateTime.now();

    final int batchSize = 100;
    int lastId = startAt;

    final Results results = await pool.query(
        "SELECT * FROM images WHERE ID >= $lastId ORDER BY ID ASC LIMIT $batchSize");
    List<Row> rows = await results.toList();

    while (rows.length > 0) {
      for (Row row in rows) {
        lastId = row.id;
        final ImportResult result = new ImportResult();
        result.batchTimestamp = batchTimestamp;
        result.source = "shimmie";
        result.fileName = "${row.id} - ${row.filename}";
        try {
          final Item newItem = new Item();
          newItem.fileName = row.filename;
          newItem.source = row.source;

          final String filename = row.hash;
          _log.info(
              "Importing file #${row.id} (${row.hash}) (${row.ext}) (${row.filename})");

          newItem.filePath = path.join(imagePath, filename.substring(0, 2), filename);

          final Query tagsQuery = await pool.prepare(
              "SELECT t.* FROM image_tags it INNER JOIN tags t ON t.id = it.tag_id WHERE image_id = ?");
          final Results tagsResult = await tagsQuery.execute([row.id]);

          final List<Row> tagRows = await tagsResult.toList();
          _log.info("Found tags: ${tagRows.length}");

          for (Row tagRow in tagRows) {
            final Tag tag = new Tag();
            final String tagText = tagRow.tag;
            if(interpretTagCategories&&tagText.contains(":")) {
              tag.category = tagText.substring(0,tagText.indexOf(":"));
              tag.id = tagText.substring(tagText.indexOf(":")+1);
              if(isNullOrWhitespace(tag.id))
                continue;
            } else {
              tag.id =tagText;
            }
            newItem.tags.add(tag);
          }

          // We support pools too, TODO: add fallback code for lack of pools table
          final Query poolsQuery = await pool.prepare(
              "SELECT p.* FROM pools p INNER JOIN pool_images pi ON p.id = pi.pool_id WHERE pi.image_id = ?");
          final Results poolsResult = await poolsQuery.execute([row.id]);

          final List<Row> poolsRows = await poolsResult.toList();
          _log.info("Found pools: ${poolsRows.length}");

          for (Row poolRow in poolsRows) {
            final Tag tag = new Tag();
            tag.id = poolRow.title;
            tag.category = "Pool";
            newItem.tags.add(tag);
          }
          _log.info(newItem.tags);

          await _createItem(newItem, result, mergeExisting);
        } catch (e, st) {
          _log.severe(e, st);
          result.result = "error";
          result.error = e.toString();

          if (stopOnError) {
            rethrow;
          }
        } finally {
          await _recordResult(result);
        }
      }
      final Results results = await pool.query(
          "SELECT * FROM images WHERE ID > $lastId ORDER BY ID ASC LIMIT $batchSize");
      rows = await results.toList();
    }
  }

  List<String> _breakDownTagString(String input) {
    final List<String> output = <String>[];
    for (Match m in tagSplitterRegExp.allMatches(input)) {
      if (isNullOrWhitespace(m.group(0))) continue;
      output.add(m.group(0));
    }
    return output;
  }

  Future<Null> _createItem(Item newItem, ImportResult result, bool mergeExisting) async {
    try {
      await itemModel.create(newItem, bypassAuthentication: true);
      result.id = newItem.id;
      _log.info("Imported new file ${result.id}");
      result.result = "added";
    } on DuplicateItemException catch (e, st) {
      if(mergeExisting) {
        _log.info("Item already exists, merging");
        final TagList newTags = new TagList.from(newItem.tags);
        final Item existingItem = await itemModel.getById(newItem.id);
        result.id = existingItem.id;
        final TagList existingTags = new TagList.from(existingItem.tags);
        existingTags.addAll(newTags);
        await itemModel.updateTags(existingItem.id, existingTags.toList(),
            bypassAuthentication: true);
        result.result = "merged";
      } else {
        _log.info("Item already exists, skipping");
        result.id = newItem.id;
        result.result = "skipped";
      }
    } catch (e, st) {
      result.id = newItem.id;
      rethrow;
    }
  }

  Future<Null> _importFromFolderRecursive(
      DateTime batchTimestamp,
      Directory currentDirectory,
      TagList parentTags,
      bool interpretShimmieNames,
      bool stopOnError,
      bool mergeExisting) async {
    await for (FileSystemEntity entity in currentDirectory.list()) {

      if (entity is Directory) {
        final TagList newTagList = new TagList.from(parentTags);
        final String dirName = path.basename(entity.path);
        for (String tagString in _breakDownTagString(dirName)) {
          newTagList.add(new Tag.withValues(tagString));
        }
        await _importFromFolderRecursive(batchTimestamp, entity, newTagList,
            interpretShimmieNames, stopOnError, mergeExisting);
      } else if (entity is File) {
        final ImportResult result = new ImportResult();
        result.source = "folder";
        result.batchTimestamp = batchTimestamp;
        try {
          result.fileName = entity.path;
          _log.info("Attempting to import ${entity.path}");
          final Item newItem = new Item();
          newItem.tags = parentTags.toList();
          if (interpretShimmieNames &&
              shimmieFileRegexp
                  .hasMatch(path.basenameWithoutExtension(entity.path))) {
            final Match m = shimmieFileRegexp
                .firstMatch(path.basenameWithoutExtension(entity.path));
            for (String tag in _breakDownTagString(m.group(1))) {
              newItem.tags.add(new Tag.withValues(tag));
            }
          }
          newItem.filePath = entity.path;
          //newItem.fileData = await getFileData(entity.path);
          newItem.fileName = path.basename(entity.path);
          newItem.extension = path.extension(entity.path).substring(1);
          await _createItem(newItem, result, mergeExisting);
          _log.info("Imported file ${entity.path}");
        } catch (e, st) {
          _log.severe(e, st);
          result.result = "error";
          result.error = e.toString();
          if (stopOnError) {
            rethrow;
          }
        } finally {
          await _recordResult(result);
        }
      }
    }
  }

  Future<Null> _recordResult(ImportResult result) async {
    result.timestamp = new DateTime.now();
    //if (isNullOrWhitespace(result.id)) throw new ArgumentError("ID is missing");
    if (isNullOrWhitespace(result.source))
      throw new ArgumentError("Source is missing");
    if (isNullOrWhitespace(result.result))
      throw new ArgumentError("Result is missing");
    if (result.batchTimestamp == null)
      throw new ArgumentError.notNull("batchTimestamp");

    if (isNotNullOrWhitespace(result.id)) {
      final File f = new File(getThumbnailFilePathForHash(result.id));
      result.thumbnailCreated = f.existsSync();
    }
    await _importResultsDataSource.record(result);
  }
}
