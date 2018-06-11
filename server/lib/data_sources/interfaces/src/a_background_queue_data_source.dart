import 'dart:async';
import 'package:logging/logging.dart';
import 'a_data_source.dart';
import 'package:dartlery/data/data.dart';
import 'package:option/option.dart';

import 'package:dice/dice.dart';
@Injectable()
abstract class ABackgroundQueueDataSource extends ADataSource {
  static final Logger _log = new Logger('ABackgroundQueueDataSource');

  Future<Null> addToQueue(String extensionId, dynamic data, {int priority});
  Future<Null> deleteItem(String id);
  Future<Option<BackgroundQueueItem>> getNextItem();
}
