import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data/data.dart';
import 'package:option/option.dart';
import 'a_id_based_data_source.dart';

import 'package:dice/dice.dart';
@Injectable()
abstract class AUserDataSource extends AIdBasedDataSource<User> {
  static final Logger _log = new Logger('AUserDataSource');

  Future<List<User>> getAdmins();

  Future<Null> setPassword(String username, String password);
  Future<Option<String>> getPasswordHash(String username);
}
