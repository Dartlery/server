import 'dart:async';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';
import 'package:meta/meta.dart';
import 'a_postgres_object_data_source.dart';

import 'constants.dart';

abstract class APostgresIdDataSource<T extends AIdData>
    extends APostgresObjectDataSource<T> with AIdBasedDataSource<T> {
  APostgresIdDataSource(PostgresConnectionPool pool) :
        super(pool);

  @override
  Future<Null> deleteById(String id) => runStatement("DELETE FROM $tableName WHERE id = @id", {"id": id});

  @override
  Future<bool> existsById(String id) => super.exists(where.eq(idField, id));

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
  Future<Option<T>> getById(String id) =>
      getForOneFromDb(where.eq(idField, id));

  @override
  Future<String> create(T object) async {
    await insertIntoDb(object);
    return object.id;
  }

  @override
  Future<String> update(String id, T object) async {
    await updateToDb(where.eq(idField, id), object);
    return object.id;
  }

  @override
  Future<IdDataList<T>> search(String query,
      {SelectorBuilder selector, String sortBy}) async {
    final List<dynamic> data =
        await super.searchAndSort(query, selector: selector, sortBy: sortBy);
    return new IdDataList<T>.copy(data);
  }
}
