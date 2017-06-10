import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data/data.dart';
import 'a_id_based_data_source.dart';

abstract class ATagCategoryDataSource extends AIdBasedDataSource<TagCategory> {
  static final Logger _log = new Logger('ATagCategoryDataSource');
}
