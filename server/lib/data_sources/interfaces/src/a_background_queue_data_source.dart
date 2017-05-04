import 'dart:async';
import 'package:logging/logging.dart';
import 'a_data_source.dart';
import 'package:dartlery/data/data.dart';
import 'package:option/option.dart';

abstract class ABackgroundQueueDataSource extends ADataSource {
  static final Logger _log = new Logger('ABackgroundQueueDataSource');

  Future<Null> addToQueue(String pluginId, String data);
  Future<Null> deleteItem(String id);
  Future<Option<BackgroundQueueItem>> getNextItem();

}
