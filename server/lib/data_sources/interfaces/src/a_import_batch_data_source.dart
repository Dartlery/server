import 'dart:async';
import 'package:logging/logging.dart';
import 'a_data_source.dart';
import 'package:dartlery/data/data.dart';
import 'package:option/option.dart';

abstract class AImportBatchDataSource extends ADataSource {
  static final Logger _log = new Logger('AImportBatchDataSource');

  Future<Null> record(ImportBatch data);
  Future<PaginatedData<ImportBatch>> get({int page: 0, int perPage});
}
