import 'dart:async';

import 'package:connection_pool/connection_pool.dart';
import 'package:dartlery/model/model.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'constants.dart';
import 'mongo_db_connection_pool.dart';
import 'mongo_extension_data_source.dart';
import 'mongo_item_data_source.dart';
import 'mongo_tag_data_source.dart';
import 'mongo_background_queue_data_source.dart';
import 'mongo_import_results_data_source.dart';

class MongoDatabase {
  static final Logger _log = new Logger('_MongoDatabase');

  static const String _settingsCollection = "settings";
  static const String _itemsCollection = "items";
  static const String _tagCategoriesCollection = "tagCategories";
  static const String _usersCollection = "users";
  static const String _backgroundQueueCollection = "backgroundQueue";
  static const String _extensionDataCollection = "extensionData";
  static const String _importResultsCollection = "importResults";

  static const String redirectEntryName = "redirect";
  static const int maxConnections = 3;

  final Db db;

  MongoDatabase(this.db);

  //db.getCollection('items').update({}, {$set: {"inTrash": false}}, {multi:true})
  Future<DbCollection> getItemsCollection() async {
    await db.createIndex(_itemsCollection,
        keys: {
          MongoItemDataSource.inTrashField: 1,
          MongoItemDataSource.uploadedField: -1
        },
        name: "UploadedIndex");
    await db.createIndex(_itemsCollection,
        keys: {
          MongoItemDataSource.inTrashField: 1,
          MongoItemDataSource.tagsField: 1,
          MongoItemDataSource.uploadedField: -1
        },
        name: "ItemTagsIndex");

    final DbCollection output = await getIdCollection(_itemsCollection);
    return output;
  }

  Future<DbCollection> getBackgroundQueueCollection() async {
    await db.createIndex(_backgroundQueueCollection,
        keys: {
          MongoBackgroundQueueDataSource.priorityField: 1,
          MongoBackgroundQueueDataSource.addedField: 1
        },
        name: "BackgroundQueueIndex");
    final DbCollection output =
        await getIdCollection(_backgroundQueueCollection);
    return output;
  }

  Future<DbCollection> getExtensionDataCollection() async {
    await db.createIndex(_extensionDataCollection,
        keys: {
          MongoExtensionDataSource.extensionIdField: 1,
          MongoExtensionDataSource.keyField: 1,
          MongoExtensionDataSource.primaryIdField: 1,
          MongoExtensionDataSource.secondaryIdField: 1
        },
        name: "ExtensionDataIndex",
        unique: true);
    await db.createIndex(_extensionDataCollection,
        keys: {
          MongoExtensionDataSource.extensionIdField: 1,
          MongoExtensionDataSource.keyField: 1
        },
        name: "ExtensionDataKeyIndex",
        unique: false);
    await db.createIndex(_extensionDataCollection,
        keys: {
          MongoExtensionDataSource.extensionIdField: 1,
          MongoExtensionDataSource.keyField: 1,
          MongoExtensionDataSource.valueField: -1
        },
        name: "ExtensionDataKeyValueDescendingIndex",
        unique: false);
    return db.collection(_extensionDataCollection);
  }

  Future<DbCollection> getImportResultsCollection() async {
    await db.createIndex(_importResultsCollection,
        keys: {
          MongoImportResultsDataSource.timestampField: -1
        },
        name: "ImportResultsTimestamp",
        unique: false);
    await db.createIndex(_importResultsCollection,
        keys: {
          MongoImportResultsDataSource.resultField: 1
        },
        name: "ImportResultsResult",
        unique: false);
    return db.collection(_importResultsCollection);
  }

  Future<DbCollection> getTagsCollection() async {
    await db.createIndex(tagsCollection,
        keys: {idField: 1, MongoTagDataSource.categoryField: 1},
        name: "IdIndex",
        unique: true);
    await db.createIndex(tagsCollection,
        keys: {MongoTagDataSource.redirectField: 1},
        name: "RedirectIndex",
        unique: false,
        sparse: true);
    await db.createIndex(tagsCollection,
        keys: {MongoTagDataSource.fullNameField: "text"}, name: "TagTextIndex");
    final DbCollection output = db.collection(tagsCollection);

    return output;
  }

  Future<DbCollection> getTagCategoriesCollection() async {
    final DbCollection output = await getIdCollection(_tagCategoriesCollection);
    return output;
  }

  Future<DbCollection> getSettingsCollection() async {
    final DbCollection output = db.collection(_settingsCollection);
    return output;
  }

  Future<DbCollection> getTransactionsCollection() async {
    final DbCollection output = db.collection("transactions");
    return output;
  }

  Future<DbCollection> getUsersCollection() async {
    final DbCollection output = await getIdCollection(_usersCollection);
    await db.createIndex(_usersCollection,
        keys: {"id": "text", "name": "text"}, name: "TextIndex");
    return output;
  }

  Future<DbCollection> getIdCollection(String collectionName) async {
    await db.createIndex(collectionName,
        keys: {idField: 1}, name: "IdIndex", unique: true);
    return db.collection(collectionName);
  }

  Future<Null> nukeDatabase() async {
    final DbCommand cmd = DbCommand.createDropDatabaseCommand(db);
    await db.executeDbCommand(cmd);
  }

  Future<Null> startTransaction() async {
    final DbCollection transactions = await getTransactionsCollection();
    await transactions.findOne({"state": "initial"});
  }
}
