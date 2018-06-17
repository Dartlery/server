import 'dart:async';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery/data/data.dart';
import 'package:meta/meta.dart';
import 'a_postgres_data_source.dart';
export 'a_postgres_data_source.dart';

abstract class APostgresObjectDataSource<T> extends APostgresDataSource {
  APostgresObjectDataSource(PostgresConnectionPool pool) : super(pool);

  String get tableCreateScript;
  String get tableName;

}
