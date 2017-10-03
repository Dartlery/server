import 'dart:async';
import 'package:logging/logging.dart';
import 'package:server/data_sources/interfaces.dart';
import 'package:dartlery/data/data.dart';
import 'package:server/data/data.dart';

abstract class AImportResultsDataSource extends ADataSource {
  static final Logger _log = new Logger('AImportResultsDataSource');

  Future<Null> record(ImportResult data);
  Future<PaginatedData<ImportResult>> get(String batchId,
      {int page: 0, int perPage});
  Future<Null> clear(String batchId, [bool everything = false]);
}
