import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data/data.dart';
import 'package:option/option.dart';
import 'a_data_source.dart';

abstract class AIdBasedDataSource<T extends AIdData> extends ADataSource {
  static final Logger _log = new Logger('AUuidBasedDataSource');

  Future<IdDataList<T>> getAll();
  Future<Option<T>> getById(String uuid);
  Future<String> create(String uuid, T t);
  Future<String> update(String uuid, T t);
  Future<Null> deleteById(String uuid);
  Future<bool> existsById(String uuid);
  Future<IdDataList<T>> search(String query);
}
