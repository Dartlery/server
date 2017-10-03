import 'dart:async';
import 'package:logging/logging.dart';
import 'package:server/data_sources/interfaces.dart';
import 'package:dartlery/data/data.dart';
import 'package:option/option.dart';

abstract class AImportBatchDataSource extends AIdBasedDataSource<ImportBatch> {
  static final Logger _log = new Logger('AImportBatchDataSource');

  Future<Null> incrementImportCount(String batchId, String result);
  Future<Null> markBatchFinished(String batchId);
}
