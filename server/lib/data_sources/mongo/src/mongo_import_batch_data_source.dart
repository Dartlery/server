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
import 'package:server/data_sources/data_sources.dart';

class MongoImportBatchDataSource extends AMongoIdDataSource<ImportBatch>
    with AImportBatchDataSource {
  static final Logger _log = new Logger('MongoImportBatchDataSource');

  MongoImportBatchDataSource(MongoDbConnectionPool pool) : super(pool);

  @override
  Logger get childLogger => _log;


  @override
  Future<Null> incrementImportCount(String batchId, String result) async {
    final Option<Map> opt = await genericFindOne(where.eq(idField, batchId));
    if (opt.isEmpty) {
      throw new NotFoundException("Batch not found: $batchId");
    }
    final Map doc = opt.first;
    if (doc[ImportBatch.importCountsField] == null) {
      doc[ImportBatch.importCountsField] = <String, num>{};
    }
    if (!doc[ImportBatch.importCountsField].containsKey(result)) {
      doc[ImportBatch.importCountsField][result] = 0;
    }
    doc[ImportBatch.importCountsField][result]++;
    await genericUpdate(where.eq(idField, batchId), doc);
  }

  @override
  Future<Null> markBatchFinished(String batchId) async {
    await genericUpdate(
        where.eq(idField, batchId), modify.set(ImportBatch.finishedField, true));
  }
}
