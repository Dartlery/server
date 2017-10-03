import 'dart:async';
import 'package:tools/tools.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';
import 'package:server/data_sources/mongo/mongo.dart';
import '../mongo.dart';

class MongoBackgroundQueueDataSource
    extends AMongoObjectDataSource<BackgroundQueueItem>
    with ABackgroundQueueDataSource {
  static final Logger _log = new Logger('MongoBackgroundQueueDataSource');
  @override
  Logger get childLogger => _log;

  static const String dataField = 'data';
  static const String addedField = "added";
  static const String extensionIdField = "extensionId";
  static const String priorityField = "priority";
  static const int _defaultPriority = 50;

  MongoBackgroundQueueDataSource(MongoDbConnectionPool pool) : super(pool);

  @override
  MongoCollection get collection => backgroundQueueCollection;

  @override
  Future<Null> addToQueue(String extensionId, dynamic data,
      {int priority: _defaultPriority}) async {
    final BackgroundQueueItem item = new BackgroundQueueItem();
    item.id = generateUuid();
    item.data = data;
    item.extensionId = extensionId;
    item.added = new DateTime.now();
    item.priority = priority;
    await super.insertIntoDb(item);
  }

  @override
  void updateMap(BackgroundQueueItem item, Map<String, dynamic> data) {
    data[idField] = item.id;
    data[dataField] = item.data;
    data[addedField] = item.added;
    data[extensionIdField] = item.extensionId;
    data[priorityField] = item.priority;
  }

  @override
  Future<BackgroundQueueItem> createObject(Map<String, dynamic> data) async {
    final BackgroundQueueItem output = new BackgroundQueueItem();
    output.id = data[idField];
    output.data = data[dataField];
    output.added = data[addedField];
    output.extensionId = data[extensionIdField];
    output.priority = data[priorityField] ?? _defaultPriority;
    return output;
  }

  @override
  Future<Null> deleteItem(String id) async {
    await super.deleteFromDb(where.eq(idField, id));
  }

  @override
  Future<Option<BackgroundQueueItem>> getNextItem() async {
    return await super.getForOneFromDb(where
        .sortBy(priorityField, descending: false)
        .sortBy(addedField, descending: false));
  }
}
