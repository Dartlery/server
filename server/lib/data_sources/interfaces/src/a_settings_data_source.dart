import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/server.dart';
import 'a_data_source.dart';

import 'package:dice/dice.dart';
@Injectable()
abstract class ASettingsDataSource extends ADataSource {
  static final Logger _log = new Logger('ASettingsModel');

  ASettingsDataSource();

  Future<Settings> get(String name);

  Future<Null> write(Settings setting, String value);
}
