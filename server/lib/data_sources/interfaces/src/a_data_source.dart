import 'dart:async';
import 'package:logging/logging.dart';

abstract class ADataSource extends Object {
  static final Logger _log = new Logger('ADataSource');
  int getOffset(int page, int perPage) => page * perPage;

  //Future<Null> prepareDataSource() async {}
}
