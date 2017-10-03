import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:server/data_sources/mongo/constants.dart';
import 'package:server/data_sources/mongo/mongo.dart';

import 'src/mongo_background_queue_data_source.dart';
import 'src/mongo_extension_data_source.dart';
import 'src/mongo_import_batch_data_source.dart';
import 'src/mongo_import_results_data_source.dart';
import 'src/mongo_item_data_source.dart';
import 'src/mongo_log_data_source.dart';
import 'src/mongo_tag_category_data_source.dart';
import 'src/mongo_tag_data_source.dart';
import 'src/mongo_user_data_source.dart';

export 'src/mongo_background_queue_data_source.dart';
export 'src/mongo_extension_data_source.dart';
export 'src/mongo_import_batch_data_source.dart';
export 'src/mongo_import_results_data_source.dart';
export 'src/mongo_item_data_source.dart';
export 'src/mongo_log_data_source.dart';
export 'src/mongo_tag_category_data_source.dart';
export 'src/mongo_tag_data_source.dart';
export 'src/mongo_user_data_source.dart';

final MongoIdCollection backgroundQueueCollection =
    new MongoIdCollection("backgroundQueue", (mongo.Db db, String name) async {
  await db.createIndex(name,
      keys: {
        MongoBackgroundQueueDataSource.priorityField: 1,
        MongoBackgroundQueueDataSource.addedField: 1
      },
      name: "BackgroundQueueIndex");
});

final MongoCollection extensionDataCollection =
    new MongoCollection("extensionData", (mongo.Db db, String name) async {
  await db.createIndex(name,
      keys: {
        MongoExtensionDataSource.extensionIdField: 1,
        MongoExtensionDataSource.keyField: 1,
        MongoExtensionDataSource.primaryIdField: 1,
        MongoExtensionDataSource.secondaryIdField: 1
      },
      name: "ExtensionDataIndex",
      unique: true);
  await db.createIndex(name,
      keys: {
        MongoExtensionDataSource.extensionIdField: 1,
        MongoExtensionDataSource.keyField: 1
      },
      name: "ExtensionDataKeyIndex",
      unique: false);
  await db.createIndex(name,
      keys: {
        MongoExtensionDataSource.extensionIdField: 1,
        MongoExtensionDataSource.keyField: 1,
        MongoExtensionDataSource.valueField: -1
      },
      name: "ExtensionDataKeyValueDescendingIndex",
      unique: false);
});

final MongoCollection importBatchCollection =
    new MongoCollection("importBatches", (mongo.Db db, String name) async {
  await db.createIndex(name,
      keys: {MongoImportBatchDataSource.timestampField: -1},
      name: "ImportBatchesTimestamp",
      unique: true);
  await db.createIndex(name,
      keys: {idField: -1}, name: "ImportBatchesIDIndex", unique: true);
});

final MongoCollection importResultsCollection =
    new MongoCollection("importResults", (mongo.Db db, String name) async {
  await db.createIndex(name,
      keys: {MongoImportResultsDataSource.timestampField: -1},
      name: "ImportResultsTimestamp",
      unique: false);
  await db.createIndex(name,
      keys: {MongoImportResultsDataSource.resultField: 1},
      name: "ImportResultsResult",
      unique: false);
});

final MongoIdCollection itemsCollection =
    new MongoIdCollection("items", (mongo.Db db, String name) async {
  await db.createIndex(name,
      keys: {
        MongoItemDataSource.inTrashField: 1,
        MongoItemDataSource.uploadedField: -1
      },
      name: "UploadedIndex");
  await db.createIndex(name,
      keys: {
        MongoItemDataSource.inTrashField: 1,
        MongoItemDataSource.tagsField: 1,
        MongoItemDataSource.uploadedField: -1
      },
      name: "ItemTagsIndex");
});

final MongoCollection logCollection =
    new MongoCollection("log", (mongo.Db db, String name) async {
  await db.createIndex(name,
      keys: {MongoLogDataSource.timestampField: -1},
      name: "LogTimestampIndex",
      unique: false);
});

final MongoCollection settingsCollection = new MongoCollection("settings");

final MongoIdCollection tagCategoriesCollection =
    new MongoIdCollection("tagCategories");

final MongoCollection tagsCollection =
    new MongoCollection("tags", (mongo.Db db, String name) async {
  await db.createIndex(name,
      keys: {idField: 1, MongoTagDataSource.categoryField: 1},
      name: "IdIndex",
      unique: true);
  await db.createIndex(name,
      keys: {MongoTagDataSource.redirectField: 1},
      name: "RedirectIndex",
      unique: false,
      sparse: true);
  await db.createIndex(name,
      keys: {MongoTagDataSource.fullNameField: "text"}, name: "TagTextIndex");
});

final MongoIdCollection usersCollection =
    new MongoIdCollection("users", (mongo.Db db, String name) async {
  await db.createIndex(name,
      keys: {"id": "text", "name": "text"}, name: "TextIndex");
});
