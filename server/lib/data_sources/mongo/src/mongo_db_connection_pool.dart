import 'dart:async';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'mongo_database.dart';
import 'package:dartlery_shared/global.dart';

import 'package:dice/dice.dart';
@Injectable()
class MongoDbConnectionPool extends ConnectionPool {
  static final Logger _log = new Logger('_MongoDbConnectionPool');

  final String uri;

  @inject
  MongoDbConnectionPool(this.uri, [int poolSize = 5]) : super(poolSize, () async {
    _log.info("Opening mongo connection");
    final Db conn = new Db(uri);
    if (await conn.open())
    return conn;
    else
    throw new Exception("Could not open connection");
  });

  Future<T> databaseWrapper<T>(Future<T> statement(MongoDatabase db),
      {int retries: 5}) async {
    // The number of retries should be at least as much as the number of connections in the connection pool.
    // Otherwise it might run out of retries before invalidating every potentially disconnected connection in the pool.
    for (int i = 0; i < retries; i++) {
      //bool closeConnection = false;
      final Db conn = await connect();

      try {
        return await statement(new MongoDatabase(conn));
      } on ConnectionException catch (e, st) {
        if (i >= retries) {
          _log.severe(
              "ConnectionException while operating on mongo database", e, st);
          rethrow;
        } else {
          _log.warning(
              "ConnectionException while operating on mongo database, retrying",
              e,
              st);
        }
        //closeConnection = true;
      } catch (e, st) {
        _log.fine("Error while operating on mongo dataabase", e, st);
        if (e.toString().contains("duplicate key")) {
          throw new DuplicateItemException("Item already exists in database");
        }
        rethrow;
      } finally {
        //this.releaseConnection(conn, markAsInvalid: closeConnection);
      }
    }
    throw new Exception("Reached unreachable code");
  }

  // Going to try without this for a bit
//  @override
//  Future<Db> connect() async {
//    Db con = await this.connect();
//
//    // Theoretically this should be able to catch closed connections, but it can't catch connections that were closed by the server without notifying the client, like when the server restarts.
//    int i = 0;
//    while (con?.conn == null || con.conn.state != State.OPEN) {
//      if (i > 5) {
//        throw new Exception(
//            "Too many attempts to fetch a connection from the pool");
//      }
//      if (con != null) {
//        _log.info(
//            "Mongo database connection has issue, returning to pool and re-fetching");
//        this.releaseConnection(con, markAsInvalid: true);
//      }
//      con = await this.getConnection();
//      i++;
//    }
//
//    return con;
//  }

  static Future<Null> testConnectionString(String connectionString) async {
    final MongoDbConnectionPool pool =
        new MongoDbConnectionPool(connectionString, 1);
    await pool.connect();
    //pool.releaseConnection(con);
    await pool.close();
  }
}
