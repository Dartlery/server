import 'dart:async';

import 'package:connection_pool/connection_pool.dart';
import 'package:dartlery/model/model.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'constants.dart';
import 'mongo_db_connection_pool.dart';

class MongoDatabase {
  static final Logger _log = new Logger('_MongoDatabase');

  static const String _settingsCollection = "settings";
  static const String _itemsCollection = "items";
  static const String _tagsCollection = "tags";
  static const String _tagCategoriesCollection = "tagCategories";
  static const String _usersCollection = "users";

  static const String redirectEntryName = "redirect";
  static const int maxConnections = 3;

  final Db db;

  MongoDatabase(this.db);


  Future<DbCollection> getItemsCollection() async {
    await db.createIndex(_itemsCollection,
        keys: {"checksum": 1}, name: "ChecksumIndex", unique: true);
    final DbCollection output =
    await getIdCollection(_itemsCollection);
    return output;
  }
  Future<DbCollection> getTagsCollection() async {
    await db.createIndex(_tagsCollection,
        keys: {r"fullName": "text"}, name: "TagTextIndex");
    final DbCollection output =  db.collection(_tagsCollection);

    await db.createIndex(_tagsCollection,
        keys: { idField: 1}, name: "ReadableIdIndex", unique: true);

    return output;
  }
  Future<DbCollection> getTagCategoriesCollection() async {
    final DbCollection output =
    await getIdCollection(_tagCategoriesCollection);
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
