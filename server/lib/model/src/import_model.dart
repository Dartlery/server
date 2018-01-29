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
import 'a_id_based_model.dart';

class ImportModel extends AIdBasedModel<ImportBatch> {
  static final Logger _log = new Logger('ImportModel');

  final ItemModel itemModel;
  final TagCategoryModel tagCategoryModel;
  final AImportBatchDataSource _importBatchDataSource;
  final AImportResultsDataSource _importResultsDataSource;
  final ABackgroundQueueDataSource _backgroundQueueDataSource;

  final RegExp fileNameTagsRegexp = new RegExp(r"^\d+ \- (.+)$");

  final RegExp tagSplitterRegExp = new RegExp("[^\\s\"']+|\"([^\"]*)\"|'([^']*)'");

  @override
  AImportBatchDataSource get dataSource => _importBatchDataSource;

  ImportModel(
      this.itemModel,
      this.tagCategoryModel,
      this._importResultsDataSource,
      this._backgroundQueueDataSource,
      this._importBatchDataSource,
      AUserDataSource userDataSource)
      : super(userDataSource);

  @override
  Logger get loggerImpl => _log;


  Future<String> createBatch(String source) async {
    final ImportBatch importBatch = new ImportBatch();
    importBatch.source = "shimmie";
    importBatch.timestamp = new DateTime.now();
    await _importBatchDataSource.create(importBatch);
    return importBatch.id;
  }

  Future<Null> clearResults(String batchId, [bool everything = false]) async {
    await validateDeletePrivileges();
    if(everything) {
      await this.delete(batchId);
    }
    await _importResultsDataSource.clear(batchId, everything);
  }

  Future<String> enqueueImportFromPath(String path,
      {bool interpretFileNames: false, bool stopOnError: false, bool mergeExisting: false}) async {
    await validateUpdatePrivilegeRequirement();

    if(isNullOrWhitespace(path)) {
      throw new ArgumentError.notNull("path");
    }
    final Directory dir = new Directory(path);
    if(!dir.existsSync()) {
      throw new ArgumentError("path not found");
    }

    final String batchId = await createBatch("shimmie");

    final Map<String, dynamic> data = <String, dynamic>{};
    data["path"] = path;
    data["interpretFileNames"] = interpretFileNames;
    data["stopOnError"] = stopOnError;
    data["batchId"] = batchId;
    data["mergeExisting"] = mergeExisting;
    await _backgroundQueueDataSource
        .addToQueue(ImportPathExtension.pluginIdStatic, data, priority: 10);
    return batchId;
  }

  Future<PaginatedData<ImportResult>> getBatchResults(String batchId,
      {int page: 0, int perPage: defaultPerPage}) async {
    await validateGetPrivileges();
    return await _importResultsDataSource.get(batchId, page: page, perPage: perPage);
  }

  Future<Null> importFromPath(String path,
      {bool interpretFileNames: false,
      bool stopOnError: false,
      String overrideBatchId: null,
      bool mergeExisting: false}) async {

    String batchId = overrideBatchId;
    if (isNullOrWhitespace(batchId)) {
      batchId = await createBatch("shimmie");
    }
    try {
      final TagList tagList = new TagList();

      await _importFromFolderRecursive(batchId, new Directory(path),
          tagList, interpretFileNames, stopOnError, mergeExisting);
    } finally {
      await _importBatchDataSource.markBatchFinished(batchId);
      _log.info("Path import end");
    }
  }

  Future<Null> importFromShimmie(String imagePath, String mysqlHost, String mysqlUser, String mysqlPassword, String mysqlDb,
      {int startAt: -1, bool stopOnError: false, bool interpretTagCategories: true, bool mergeExisting: true}) async {
    final ConnectionPool pool = new ConnectionPool(
        host: mysqlHost,
        user: mysqlUser,
        password: mysqlPassword,
        db: mysqlDb);

    final int batchSize = 100;
    int lastId = startAt;

    final ImportBatch importBatch = new ImportBatch();
    importBatch.source = "shimmie";
    importBatch.timestamp = new DateTime.now();
    await _importBatchDataSource.create(importBatch);

    try {
      final Results results = await pool.query(
          "SELECT * FROM images WHERE ID >= $lastId ORDER BY ID ASC LIMIT $batchSize");
      List<Row> rows = await results.toList();

      while (rows.length > 0) {
        for (Row row in rows) {
          lastId = row.id;
          final ImportResult result = new ImportResult();
          result.batchId = importBatch.id;
          result.fileName = "${row.id} - ${row.filename}";
          try {
            final Item newItem = new Item();
            newItem.fileName = row.filename;
            newItem.source = row.source;

            final String filename = row.hash;
            _log.info(
                "Importing file #${row.id} (${row.hash}) (${row.ext}) (${row
                    .filename})");

            newItem.filePath =
                path.join(imagePath, filename.substring(0, 2), filename);

            final Query tagsQuery = await pool.prepare(
                "SELECT t.* FROM image_tags it INNER JOIN tags t ON t.id = it.tag_id WHERE image_id = ?");
            final Results tagsResult = await tagsQuery.execute([row.id]);

            final List<Row> tagRows = await tagsResult.toList();
            _log.info("Found tags: ${tagRows.length}");

            for (Row tagRow in tagRows) {
              final Tag tag = new Tag();
              final String tagText = tagRow.tag;
              if (interpretTagCategories && tagText.contains(":")) {
                tag.category = tagText.substring(0, tagText.indexOf(":"));
                tag.id = tagText.substring(tagText.indexOf(":") + 1);
                if (isNullOrWhitespace(tag.id))
                  continue;
              } else {
                tag.id = tagText;
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
    } finally {
      await _importBatchDataSource.markBatchFinished(importBatch.id);
      _log.info("Shimmie import end");
    }
  }

  List<String> _breakDownTagString(String input) {
    final List<String> output = <String>[];
    for (Match m in tagSplitterRegExp.allMatches(input)) {
      if (isNotNullOrWhitespace(m.group(1))) {
        output.add(m.group(1));
      } else if (isNotNullOrWhitespace(m.group(2))){
        output.add(m.group(2));
      } else {
        output.add(m.group(0));
      }

    }
    return output;
  }

  Future<Null> _createItem(Item newItem, ImportResult result, bool mergeExisting) async {
    try {
      await itemModel.create(newItem, bypassAuthentication: true);
      result.itemId = newItem.id;
      _log.info("Imported new file ${result.itemId}");
      result.result = "added";
    } on DuplicateItemException catch (e, st) {
      if(mergeExisting) {
        _log.info("Item already exists, merging");
        final TagList newTags = new TagList.from(newItem.tags);
        final Item existingItem = await itemModel.getById(newItem.id, bypassAuthentication: true);
        result.itemId = existingItem.id;
        final TagList existingTags = new TagList.from(existingItem.tags);
        existingTags.addAll(newTags);
        await itemModel.updateTags(existingItem.id, existingTags.toList(),
            bypassAuthentication: true);
        result.result = "merged";
      } else {
        _log.info("Item already exists, skipping");
        result.itemId = newItem.id;
        result.result = "skipped";
      }
    } catch (e, st) {
      result.itemId = newItem.id;
      rethrow;
    }
  }

  Future<Null> _importFromFolderRecursive(
      String batchId,
      Directory currentDirectory,
      TagList parentTags,
      bool interpretFileNames,
      bool stopOnError,
      bool mergeExisting,
      {String autoCategory}) async {
    await for (FileSystemEntity entity in currentDirectory.list()) {

      if (entity is Directory) {
        final TagList newTagList = new TagList.from(parentTags);
        final String dirName = path.basename(entity.path);

        String newAutoCategory;
        for (String tagString in _breakDownTagString(dirName)) {
          final Tag newTag = Tag.parse(tagString);
          if(isNullOrWhitespace(newTag.id)) {
            newAutoCategory = newTag.category;
            continue;
          }
          if(isNotNullOrWhitespace(autoCategory)&&isNullOrWhitespace(newTag.category)) {
            newTag.category = autoCategory;
          }
          newTagList.add(newTag);
        }

        await _importFromFolderRecursive(batchId, entity, newTagList,
            interpretFileNames, stopOnError, mergeExisting, autoCategory:  newAutoCategory);
      } else if (entity is File) {
        final ImportResult result = new ImportResult();
        result.batchId = batchId;
        try {
          result.fileName = entity.path;
          _log.info("Attempting to import ${entity.path}");
          final Item newItem = new Item();
          newItem.tags = parentTags.toList();
          if (interpretFileNames &&
              fileNameTagsRegexp
                  .hasMatch(path.basenameWithoutExtension(entity.path))) {
            final Match m = fileNameTagsRegexp
                .firstMatch(path.basenameWithoutExtension(entity.path));
            for (String tag in _breakDownTagString(m.group(1))) {
              newItem.tags.add(new Tag.withValues(tag));
            }
          }
          newItem.filePath = entity.path;
          //newItem.fileData = await getFileData(entity.path);
          newItem.fileName = path.basename(entity.path);
          dynamic extension = path.extension(entity.path);
          if(isNullOrWhitespace(extension)) {
            final dynamic mime = await mediaMimeResolver.getMimeTypeForFile(entity.path);
            if(MimeTypes.extensions.containsKey(mime)) {
              extension = MimeTypes.extensions[mime];
            } else {
              throw new Exception("Unrecognized mime type: $mime");
            }
          } else {
            extension = extension.substring(1);
          }
          newItem.extension = extension;
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
    if(isNullOrWhitespace(result.batchId))
      throw new ArgumentError.notNull("batchId");
    if (isNullOrWhitespace(result.result))
      throw new ArgumentError("Result is missing");

    if (isNotNullOrWhitespace(result.itemId)) {
      final File f = new File(getThumbnailFilePathForHash(result.itemId));
      result.thumbnailCreated = f.existsSync();
    }
    await _importResultsDataSource.record(result);
    await _importBatchDataSource.incrementImportCount(result.batchId, result.result);

  }
}
