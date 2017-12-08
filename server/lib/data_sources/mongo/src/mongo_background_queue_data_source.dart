import 'dart:async';
import 'package:tools/tools.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';
import 'package:server/data_sources/mongo/mongo.dart';
import '../mongo.dart';
import 'package:server/data_sources/data_sources.dart';

class MongoBackgroundQueueDataSource
    extends AMongoObjectDataSource<BackgroundQueueItem>
    with ABackgroundQueueDataSource {
  static final Logger _log = new Logger('MongoBackgroundQueueDataSource');
  @override
  Logger get childLogger => _log;



  MongoBackgroundQueueDataSource(MongoDbConnectionPool pool) : super(pool);

  @override
  Future<Null> addToQueue(String extensionId, dynamic data,
      {int priority: BackgroundQueueItem.defaultPriority}) async {
    final BackgroundQueueItem item = new BackgroundQueueItem();
    item.id = generateUuid();
    item.data = data;
    item.extensionId = extensionId;
    item.added = new DateTime.now();
    item.priority = priority;
    await super.insertIntoDb(item);
  }

  @override
  Future<Null> deleteItem(String id) async {
    await super.deleteFromDb(where.eq(idField, id));
  }

  @override
  Future<Option<BackgroundQueueItem>> getNextItem() async {
    return await super.getForOneFromDb(where
        .sortBy(BackgroundQueueItem.priorityField, descending: false)
        .sortBy(BackgroundQueueItem.addedField, descending: false));
  }
}
