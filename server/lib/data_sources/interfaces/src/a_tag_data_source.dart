import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data/data.dart';
import 'a_two_id_based_data_source.dart';

abstract class ATagDataSource extends ATwoIdBasedDataSource<Tag> {
  static final Logger _log = new Logger('ATagDataSource');

  Future<IdDataList<Tag>> getByIds(List<String> ids);
}
