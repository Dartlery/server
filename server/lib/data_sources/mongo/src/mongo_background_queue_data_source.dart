import 'dart:async';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:dartlery_shared/global.dart';
import 'a_mongo_two_id_data_source.dart';
import 'constants.dart';
import 'package:option/option.dart';
import 'a_mongo_data_source.dart';

class MongoBackgroundQueueDataSource extends AMongoObjectDataSource<BackgroundQueueItem> with ABackgroundQueueDataSource {
  static final Logger _log = new Logger('MongoBackgroundQueueDataSource');

  static const String dataField = 'data';
  static const String addedField = "added";
  static const String pluginIdField = "pluginId";

  MongoBackgroundQueueDataSource(MongoDbConnectionPool pool): super(pool);


  @override
  Future<DbCollection> getCollection(MongoDatabase con) =>
      con.getBackgroundQueueCollection();

  @override
  Future<Null> addToQueue(String pluginId, dynamic data) async {
    final BackgroundQueueItem item = new BackgroundQueueItem();
    item.id = generateUuid();
    item.data = data;
    item.pluginId = pluginId;
    item.added = new DateTime.now();
    await super.insertIntoDb(item);
  }

  @override
  void updateMap(BackgroundQueueItem item, Map<String, dynamic> data) {
    data[idField] = item.id;
    data[dataField] = item.data;
    data[addedField] = item.added;
    data[pluginIdField] = item.pluginId;
  }

  @override
  BackgroundQueueItem createObject(Map<String,dynamic> data) {
    final BackgroundQueueItem output = new BackgroundQueueItem();
    output.id = data[idField];
    output.data = data[dataField];
    output.added = data[addedField];
    output.pluginId = data[pluginIdField];
    return output;
  }

  @override
  Future<Null> deleteItem(String id) async {
    await super.deleteFromDb(where.eq(idField, id));
  }

  @override
  Future<Option<BackgroundQueueItem>> getNextItem() async {
    return await super.getForOneFromDb(where.sortBy(addedField, descending: false));
  }

}
