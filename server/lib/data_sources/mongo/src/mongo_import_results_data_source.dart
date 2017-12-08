import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:server/data_sources/mongo/mongo.dart';
import '../mongo.dart';
import 'package:server/data/data.dart';

class MongoImportResultsDataSource extends AMongoObjectDataSource<ImportResult>
    with AImportResultsDataSource {
  static final Logger _log = new Logger('MongoImportResultsDataSource');
  static const String fileNameField = "fileName";

  static const String itemIdField = "itemId";
  static const String batchIdField = "batchId";
  static const String resultField = "result";
  static const String errorField = "error";
  static const String sourceField = "source";
  static const String timestampField = "timestamp";
  static const String batchTimestampField = "batchTimestamp";
  static const String thumbnailCreatedField = "thumbnailCreated";
  MongoImportResultsDataSource(MongoDbConnectionPool pool) : super(pool);

  @override
  Logger get childLogger => _log;

  Future<Null> clear(String batchId, [bool everything = false]) async {
    if (!everything) {
      await deleteFromDb(where
          .eq(batchIdField, batchId)
          .nin(resultField, ["error", "warning"]));
    } else {
      await deleteFromDb(where.eq(batchIdField, batchId));
    }
  }

  @override
  Future<ImportResult> createObject(Map<String, dynamic> data) async {
    final ImportResult output = new ImportResult();
    output.batchId = data[batchIdField];
    output.itemId = data[itemIdField];
    output.fileName = data[fileNameField];
    output.result = data[resultField];
    output.error = data[errorField];
    output.thumbnailCreated = data[thumbnailCreatedField];
    output.timestamp = data[timestampField];
    return output;
  }

  Future<PaginatedData<ImportResult>> get(String batchId,
      {int page: 0, int perPage}) async {
    return await getPaginatedFromDb(where
        .eq(batchIdField, batchId)
        .sortBy(timestampField, descending: true));
  }

  @override
  Future<Null> record(ImportResult data) async {
    await insertIntoDb(data);
  }

  @override
  void updateMap(ImportResult item, Map<String, dynamic> data) {
    data[batchIdField] = item.batchId;
    data[itemIdField] = item.itemId;
    data[fileNameField] = item.fileName;
    data[resultField] = item.result;
    data[thumbnailCreatedField] = item.thumbnailCreated;
    data[errorField] = item.error;
    data[timestampField] = item.timestamp;
  }
}
