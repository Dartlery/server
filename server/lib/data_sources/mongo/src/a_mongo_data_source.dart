import 'package:dartlery_shared/global.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';
import 'mongo_database.dart';
import 'package:meta/meta.dart';
import 'mongo_db_connection_pool.dart';
export 'mongo_db_connection_pool.dart';
export 'mongo_database.dart';

abstract class AMongoDataSource {
  @protected
  Logger get childLogger;


  final MongoDbConnectionPool dbConnectionPool;
  AMongoDataSource(this.dbConnectionPool);

  int getOffset(int page, int perPage) => page * perPage;

  Future<T> _databaseWrapper<T>(
          Future<T> statement(MongoDatabase db),
          {int retries: 5})  async {
      return await dbConnectionPool.databaseWrapper<T>(statement, retries: retries);
  }


  @protected
  Future<T> collectionWrapper<T>(
          Future<T> statement(DbCollection c)) =>
      _databaseWrapper((MongoDatabase con) async =>
          await statement(await getCollection(con)));

  @protected
  Future<Null> deleteFromDb(dynamic selector) async {
    await collectionWrapper((DbCollection collection) async {
      await collection.remove(selector);
    });
  }

  @protected
  Future<DbCollection> getCollection(MongoDatabase con);

  @protected
  Future<dynamic> genericUpdate(dynamic selector, dynamic document,
      {bool multiUpdate: false}) async {
    return await collectionWrapper((DbCollection collection) async {
      return await collection.update(selector, document,
          multiUpdate: multiUpdate);
    });
  }

  @protected
  Future<dynamic> aggregate(List<dynamic> pipeline) async {
    return await collectionWrapper((DbCollection collection) async {
      return await collection.aggregate(pipeline);
    });
  }

  @protected
  Future<bool> exists(dynamic selector) async {
    return await collectionWrapper((DbCollection collection) async {
      final int count = await collection.count(selector);
      return count > 0;
    });
  }

  @protected
  Future<Option<dynamic>> genericFindOne(SelectorBuilder selector) async {
    final List<dynamic> output = await genericFind(selector.limit(1));
    if (output.length == 0) return new None<dynamic>();
    return new Some<dynamic>(output[0]);
  }

  @protected
  Future<List<Map>> genericFind(SelectorBuilder selector) async {
    return await collectionWrapper((DbCollection collection) async {
      final Stream<dynamic> str = collection.find(selector);
      final List<dynamic> output = await str.toList();
      return output;
    });
  }

  Future<Stream<Map>> genericFindStream(SelectorBuilder selector) async {
    return await collectionWrapper((DbCollection collection) async {
      return collection.find(selector);
    });
  }

  @protected
  Future<int> genericCount(SelectorBuilder selector) async {
    return await collectionWrapper((DbCollection collection) async {
      return collection.count(selector);
    });
  }
}
