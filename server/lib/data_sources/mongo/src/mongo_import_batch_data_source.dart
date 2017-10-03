import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:dartlery_shared/global.dart';
import 'package:tools/tools.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';

import 'package:server/data_sources/mongo/mongo.dart';
import '../mongo.dart';

class MongoImportBatchDataSource extends AMongoIdDataSource<ImportBatch>
    with AImportBatchDataSource {
  static final Logger _log = new Logger('MongoImportBatchDataSource');

  static const String timestampField = "timestamp";
  static const String importCountsField = "importCounts";
  static const String sourceField = "source";
  static const String finishedField = "finished";

  MongoImportBatchDataSource(MongoDbConnectionPool pool) : super(pool);

  @override
  Logger get childLogger => _log;

  @override
  Future<ImportBatch> createObject(Map<String, dynamic> data) async {
    final ImportBatch output = new ImportBatch();
    AMongoIdDataSource.setIdForData(output, data);
    output.source = data[sourceField];
    output.importCounts = data[importCountsField];
    output.finished = data[finishedField];
    output.timestamp = data[timestampField];
    return output;
  }

  @override
  MongoCollection get collection => importBatchCollection;

  @override
  void updateMap(ImportBatch item, Map<String, dynamic> data) {
    super.updateMap(item, data);
    data[importCountsField] = item.importCounts;
    data[sourceField] = item.source;
    data[timestampField] = item.timestamp;
    data[finishedField] = item.finished;
  }

  @override
  Future<Null> incrementImportCount(String batchId, String result) async {
    final Option<Map> opt = await genericFindOne(where.eq(idField, batchId));
    if (opt.isEmpty) {
      throw new NotFoundException("Batch not found: $batchId");
    }
    final Map doc = opt.first;
    if (doc[importCountsField] == null) {
      doc[importCountsField] = <String, num>{};
    }
    if (!doc[importCountsField].containsKey(result)) {
      doc[importCountsField][result] = 0;
    }
    doc[importCountsField][result]++;
    await genericUpdate(where.eq(idField, batchId), doc);
  }

  @override
  Future<Null> markBatchFinished(String batchId) async {
    await genericUpdate(
        where.eq(idField, batchId), modify.set(finishedField, true));
  }
}
