import 'dart:async';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';
import 'package:connection_pool/connection_pool.dart';
import 'package:dartlery_shared/global.dart';
import '../../../src/database_info.dart';

class PostgresConnectionPool extends ConnectionPool<PostgreSQLConnection> {
  static final Logger _log = new Logger('PostgresConnectionPool');

  final PostgresDatabaseInfo dbInfo;

  PostgresConnectionPool(this.dbInfo, [int poolSize = 5]) : super(poolSize);

  @override
  Future<Null> closeConnection(PostgreSQLConnection conn) async {
    _log.info("Closing postgres connection");
    await conn.close();
  }

  @override
  Future<PostgreSQLConnection> openNewConnection() async {
    _log.info("Opening mongo connection");
    final PostgreSQLConnection conn = new PostgreSQLConnection(dbInfo.host, dbInfo.port, dbInfo.databaseName, username: dbInfo.username, password: dbInfo.password, useSSL: dbInfo.useSSL );
    if (await conn.open())
      return conn;
    else
      throw new Exception("Could not open connection");
  }

  Future<T> databaseWrapper<T>(Future<T> statement(PostgreSQLConnection db),
      {int retries: 5}) async {
    // The number of retries should be at least as much as the number of connections in the connection pool.
    // Otherwise it might run out of retries before invalidating every potentially disconnected connection in the pool.
    for (int i = 0; i < retries; i++) {
      bool closeConnection = false;
      final ManagedConnection<PostgreSQLConnection> conn = await _getConnection();

      try {
        return await statement(conn.conn);
      } on PostgreSQLException catch (e, st) {
        if (i >= retries) {
          _log.severe(
              "ConnectionException while operating on postgres database", e, st);
          rethrow;
        } else {
          _log.warning(
              "ConnectionException while operating on postgres database, retrying",
              e,
              st);
        }
        closeConnection = true;
      } catch (e, st) {
        _log.fine("Error while operating on postgres database", e, st);
        if (e.toString().contains("duplicate key")) {
          throw new DuplicateItemException("Item already exists in database");
        }
        rethrow;
      } finally {
        this.releaseConnection(conn, markAsInvalid: closeConnection);
      }
    }
    throw new Exception("Reached unreachable code");
  }

  Future<ManagedConnection<PostgreSQLConnection>> _getConnection() async {
    ManagedConnection<PostgreSQLConnection> con = await this.getConnection();

    // Theoretically this should be able to catch closed connections, but it can't catch connections that were closed by the server without notifying the client, like when the server restarts.
    int i = 0;
    while (con?.conn == null || con.conn.isClosed) {
      if (i > 5) {
        throw new Exception(
            "Too many attempts to fetch a connection from the pool");
      }
      if (con != null) {
        _log.info(
            "Mongo database connection has issue, returning to pool and re-fetching");
        this.releaseConnection(con, markAsInvalid: true);
      }
      con = await this.getConnection();
      i++;
    }

    return con;
  }

  static Future<Null> testConnectionString(PostgresDatabaseInfo dbInfo) async {
    final PostgresConnectionPool pool =
        new PostgresConnectionPool(dbInfo, 1);
    final ManagedConnection<PostgreSQLConnection> con = await pool.getConnection();
    pool.releaseConnection(con);
    await pool.closeConnections();
  }
}
