import 'dart:async';
import 'package:logging/logging.dart';
import 'a_data_source.dart';
import 'package:dartlery/data/data.dart';
import 'package:option/option.dart';
import 'a_id_based_data_source.dart';

import 'package:dice/dice.dart';
@Injectable()
abstract class AImportBatchDataSource extends AIdBasedDataSource<ImportBatch> {
  static final Logger _log = new Logger('AImportBatchDataSource');

  Future<Null> incrementImportCount(String batchId, String result);
  Future<Null> markBatchFinished(String batchId);
}
