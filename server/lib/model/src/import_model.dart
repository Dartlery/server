import 'package:dartlery_shared/tools.dart';
import 'package:dartlery/tools.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/server.dart';
import 'dart:io';
import 'package:sqljocky/sqljocky.dart';
import 'item_model.dart';
import 'tag_category_model.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/data_sources/data_sources.dart';

class ImportModel {
  static final Logger _log = new Logger('ImportModel');

  final ItemModel itemModel;
  final TagCategoryModel tagCategoryModel;
  final AImportResultsDataSource _importResultsDataSource;


  ImportModel(this.itemModel, this.tagCategoryModel, this._importResultsDataSource);


  Future<Null> recordResult(ImportResult result) async {
    result.timestamp = new DateTime.now();
    if(StringTools.isNotNullOrWhitespace(result.id)) {
      final File f = new File(getThumbnailFilePathForHash(result.id));
      result.thumbnailCreated = f.existsSync();
    }
    await _importResultsDataSource.record(result);
  }

  Future<Null> importFromShimmie({bool stopOnError: false}) async {
    final ConnectionPool pool = new ConnectionPool(
        host: "192.168.1.10",
        user: "dartlery",
        password: "dartlery",
        db: "shimmie_rand");

    final int batchSize = 100;
    int lastId = -1;

    final Results results = await pool.query(
        "SELECT * FROM images ORDER BY ID ASC LIMIT $batchSize WHERE ID > $lastId");
    List<Row> rows = await results.toList();


    while (rows.length > 0) {
      for (Row row in rows) {
        lastId = row.id;
        final ImportResult result = new ImportResult();
        result.source = "shimmie";
        try {
          result.fileName = "${row.id} - ${row.filename}";
        final Item newItem = new Item();
          newItem.fileName = row.filename;
          newItem.source = row.source;


        final String filename = row.hash;
        _log.info("Importing file #${row.id} (${row.hash}) (${row.ext}) (${row.filename})");

        final File f = new File(path.join(r"\\darkholme\shimmie_data\images",
            filename.substring(0, 2), filename));
        RandomAccessFile raf;
        try {
          raf = await f.open();
          final int length = await raf.length();
          newItem.fileData = await raf.read(length);
        } finally {
          if (raf != null) await raf.close();
        }

        final Query tagsQuery = await pool.prepare(
            "SELECT t.* FROM image_tags it INNER JOIN tags t ON t.id = it.tag_id WHERE image_id = ?");
        final Results tagsResult = await tagsQuery.execute([row.id]);

        final List<Row> tagRows = await tagsResult.toList();
        _log.info("Found tags: ${tagRows.length}");

        for (Row tagRow in tagRows) {
          final Tag tag = new Tag();
          tag.id = tagRow.tag;
          newItem.tags.add(tag);
        }

        // We support pools too, TODO: add fallback code for lack of pools table
        final Query poolsQuery = await pool.prepare(
            "SELECT p.* FROM pools p INNER JOIN pool_images pi ON p.id = pi.pool_id WHERE pi.image_id = ?");
        final Results poolsResult = await poolsQuery.execute([row.id]);

        final List<Row> poolsRows = await poolsResult.toList();
        _log.info("Found pools: ${poolsRows.length}");

        TagCategory poolTagCategory;
        try {
          poolTagCategory = await tagCategoryModel.getById("Pool", bypassAuthentication: true);
        } on NotFoundException catch (e,st) {
          poolTagCategory = new TagCategory();
          poolTagCategory.id = "Pool";
          poolTagCategory.color = "#000000";
          await tagCategoryModel.create(poolTagCategory, bypassAuthentication: true);
        }

        for (Row poolRow in poolsRows) {
          final Tag tag = new Tag();
          tag.id = poolRow.title;
          tag.category = poolTagCategory.id;
          newItem.tags.add(tag);
        }


        await _createItem(newItem, result);
        } catch(e,st) {
          _log.severe(e,st);
          result.result = "error";
          result.error = e.toString();

          if(stopOnError) {
            rethrow;
          }
        } finally {
          await recordResult(result);
        }
      }
      final Results results = await pool.query(
          "SELECT * FROM images  ORDER BY ID ASC LIMIT $batchSize WHERE ID > $lastId");
      rows = await results.toList();
    }

  }

  Future<Null> _createItem(Item newItem, ImportResult result) async {
    try {
      result.id = await itemModel.create(newItem, bypassAuthentication: true);
      _log.info("Imported new file ${result.id}");
      result.result = "added";
    } on DuplicateItemException {
      _log.info("Item already exists, merging");
      final TagList newTags = new TagList.from(newItem.tags);
      final Item existingItem = await itemModel.getById(newItem.id);
      final TagList existingTags = new TagList.from(existingItem.tags);
      existingTags.addAll(newTags);
      await itemModel.updateTags(existingItem.id, existingTags.toList(), bypassAuthentication: true);
      result.result = "merged";
    }
  }

  final RegExp shimmieFileRegexp = new RegExp(r"^\d+ \- (.+)$");
  final RegExp tagSplitterRegExp = new RegExp(r'[\""].+?[\""]|[^ ]+');

  Future<Null> importFromPath(String path, {bool interpretShimmieNames: false, bool stopOnError: false}) async {
    final TagList tagList = new TagList();

    await _importFromFolderRecursive(new Directory(path), tagList, interpretShimmieNames, stopOnError);
  }

  Future<PaginatedData<ImportResult>> getResults({ int page: 0, int perPage: defaultPerPage}) async {
    return await _importResultsDataSource.get(page: page, perPage: perPage);
  }

  List<String> breakDownTagString(String input) {
    final List<String> output = <String>[];
    for(Match m in tagSplitterRegExp.allMatches(input)) {
      if(StringTools.isNullOrWhitespace(m.group(0)))
        continue;
      output.add(m.group(0));
    }
    return output;
  }

  Future<Null> _importFromFolderRecursive(Directory currentDirectory, TagList parentTags, bool interpretShimmieNames, bool stopOnError) async {
    for(FileSystemEntity entity in currentDirectory.listSync()) {
      if(entity is Directory) {
        final TagList newTagList = new TagList.from(parentTags);
        final String dirName = path.basename(entity.path);
        for(String tagString in breakDownTagString(dirName)) {
          newTagList.add(new Tag.withValues(tagString));
        }
        await _importFromFolderRecursive(entity, newTagList, interpretShimmieNames, stopOnError);
      } else if(entity is File) {
        final ImportResult result = new ImportResult();
        try {
          result.fileName = path.basename(entity.path);
          _log.info("Attempting to import ${entity.path}");
          final Item newItem = new Item();
          newItem.tags = parentTags.toList();
          if (interpretShimmieNames && shimmieFileRegexp.hasMatch(
              path.basenameWithoutExtension(entity.path))) {
            final Match m = shimmieFileRegexp.firstMatch(
                path.basenameWithoutExtension(entity.path));
            for (String tag in breakDownTagString(m.group(1))) {
              newItem.tags.add(new Tag.withValues(tag));
            }
          }
          newItem.fileData = await getFileData(entity.path);
          newItem.fileName = result.fileName;
          await _createItem(newItem, result);
          _log.info("Imported file ${entity.path}");
        } catch(e,st) {
          _log.severe(e,st);
          result.result = "error";
          result.error = e.toString();
          if(stopOnError) {
            rethrow;
          }
        } finally{
          await recordResult(result);
        }
      }
    }
  }
}