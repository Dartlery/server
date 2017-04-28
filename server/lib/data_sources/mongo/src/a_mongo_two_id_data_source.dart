import 'dart:async';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';
import 'a_mongo_object_data_source.dart';
import 'package:meta/meta.dart';

export 'a_mongo_object_data_source.dart';
import 'constants.dart';

abstract class AMongoTwoIdDataSource<T extends AIdData>
    extends AMongoObjectDataSource<T> with ATwoIdBasedDataSource<T> {

  AMongoTwoIdDataSource(MongoDbConnectionPool pool): super(pool);

  String get secondIdField;


  @override
  Future<Null> deleteById(String id, String id2) =>
      deleteFromDb(where.eq(idField, id).and(where.eq(secondIdField, id2)));

  @override
  Future<bool> existsById(String id, String id2) =>
      super.exists(where.eq(idField, id).and(where.eq(secondIdField, id2)));

  @override
  Future<IdDataList<T>> getAll({String sortField: null}) =>
      getListFromDb(where.sortBy(sortField ?? idField));

  Future<PaginatedIdData<T>> getPaginated(
          {String sortField: null,
          int offset: 0,
          int limit: paginatedDataLimit}) =>
      getPaginatedListFromDb(where.sortBy(sortField ?? idField),
          offset: offset, limit: limit);

  @override
  Future<Option<T>> getById(String id, String id2) =>
      getForOneFromDb(where.eq(idField, id).and(where.eq(secondIdField, id2)));

  @override
  Future<String> create(T object) async {
    await insertIntoDb(object);
    return object.id;
  }

  @override
  Future<String> update(String id, String id2, T object) async {
    await updateToDb(where.eq(idField, id).and(where.eq(secondIdField, id2)), object);
    return object.id;
  }

  @override
  void updateMap(AIdData item, Map<String, dynamic> data) {
    staticUpdateMap(item, data);
  }
  static void staticUpdateMap(AIdData item, Map<String, dynamic> data) {
    data[idField] = item.id;
  }

  static void setIdForData(
      AIdData item, Map<String, dynamic> data) {
    item.id = data[idField];
  }

  @protected
  Future<PaginatedIdData<T>> getPaginatedListFromDb(SelectorBuilder selector,
          {int offset: 0,
          int limit: paginatedDataLimit,
          String sortField: idField}) async =>
      new PaginatedIdData<T>.copyPaginatedData(await getPaginatedFromDb(
          selector,
          offset: offset,
          limit: limit,
          sortField: sortField));

  @override
  Future<PaginatedIdData<T>> searchPaginated(String query,
          {SelectorBuilder selector,
          int offset: 0,
          int limit: paginatedDataLimit}) async =>
      new PaginatedIdData<T>.copyPaginatedData(
          await super.searchPaginated(query, offset: offset, limit: limit));

  @protected
  Future<IdDataList<T>> getListFromDb(dynamic selector) async =>
      new IdDataList<T>.copy(await getFromDb(selector));

  @override
  Future<IdDataList<T>> search(String query,
      {SelectorBuilder selector, String sortBy}) async {
    final List<dynamic> data =
        await super.searchAndSort(query, selector: selector, sortBy: sortBy);
    return new IdDataList<T>.copy(data);
  }
}
