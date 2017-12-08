import 'dart:async';
import 'package:tools/tools.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../mongo.dart';
import 'package:server/data_sources/mongo/mongo.dart';

class MongoLogDataSource extends AMongoObjectDataSource<LogEntry>
    with ALogDataSource {
  static final Logger _log = new Logger('MongoLogDataSource');
  @override
  Logger get childLogger => _log;

  static const String timestampField = 'timestamp';
  static const String messageField = 'message';
  static const String loggerField = 'logger';
  static const String levelField = 'level';
  static const String stackTraceField = 'stackTrace';
  static const String errorField = 'error';

  MongoLogDataSource(MongoDbConnectionPool pool) : super(pool);

  @override
  Future<Null> create(LogEntry data) async {
    await insertIntoDb(data);
  }

  @override
  void updateMap(LogEntry item, Map<String, dynamic> data) {
    data[timestampField] = item.timestamp;
    data[messageField] = item.message;
    data[loggerField] = item.logger;
    data[levelField] = item.level;
    data[stackTraceField] = item.stackTrace;
    data[errorField] = item.error;
  }

  @override
  Future<LogEntry> createObject(Map<String, dynamic> data) async {
    final LogEntry output = new LogEntry();
    output.timestamp = data[timestampField];
    output.message = data[messageField];
    output.logger = data[loggerField];
    output.level = data[levelField];
    output.stackTrace = data[stackTraceField];
    output.error = data[errorField];
    return output;
  }
}
