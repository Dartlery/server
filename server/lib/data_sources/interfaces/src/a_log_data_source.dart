import 'dart:async';
import 'package:logging/logging.dart';
import 'a_data_source.dart';
import 'package:dartlery/data/data.dart';
import 'package:option/option.dart';

import 'package:dice/dice.dart';
@Injectable()
abstract class ALogDataSource extends ADataSource {
  static final Logger _log = new Logger('ALogDataSource');

  Future<Null> create(LogEntry data);
}
