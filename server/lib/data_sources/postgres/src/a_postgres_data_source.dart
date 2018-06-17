import 'dart:async';

import 'package:dartlery_shared/global.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';

import '../../interfaces/interfaces.dart' show ADataSource;
import 'postgres_connection_pool.dart';

export 'postgres_connection_pool.dart';
export 'package:postgres/postgres.dart';
import 'package:postgres/postgres.dart';
export 'sql_query.dart';

abstract class APostgresDataSource extends ADataSource {
  final PostgresConnectionPool dbConnectionPool;

  APostgresDataSource(this.dbConnectionPool);

  @protected
  Logger get childLogger;


  Future<dynamic> runStatement(String statement, Map<String, dynamic> parameters) {
    return dbConnectionPool.databaseWrapper((PostgreSQLConnection con) {
      return con.execute(statement, substitutionValues: parameters);
    });
  }

}
