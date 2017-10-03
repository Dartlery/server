import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data/data.dart';
import 'package:server/data_sources/interfaces.dart';

abstract class ATagCategoryDataSource extends AIdBasedDataSource<TagCategory> {
  static final Logger _log = new Logger('ATagCategoryDataSource');
}
