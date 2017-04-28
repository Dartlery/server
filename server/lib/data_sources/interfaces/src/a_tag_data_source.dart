import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data/data.dart';
import 'a_id_based_data_source.dart';

abstract class ATagDataSource extends AIdBasedDataSource<Tag> {
  static final Logger _log = new Logger('ATagDataSource');

  Future<IdDataList<Tag>> getByUuids(List<String> uuids);
}
