import 'dart:async';
import 'package:logging/logging.dart';
import 'package:server/data_sources/interfaces.dart';
import 'package:dartlery/data/data.dart';
import 'package:option/option.dart';

abstract class ABackgroundQueueDataSource implements ADataSource {
  static final Logger _log = new Logger('ABackgroundQueueDataSource');

  Future<Null> addToQueue(String extensionId, dynamic data, {int priority});
  Future<Null> deleteItem(String id);
  Future<Option<BackgroundQueueItem>> getNextItem();
}
