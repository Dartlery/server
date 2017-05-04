import 'dart:async';
import 'package:dartlery/data/data.dart';
abstract class APlugin {
  String get pluginId;

  Future<Null> onCreatingItem(Item item) async {}
  Future<Null> onBackgroundCycle(BackgroundQueueItem item) async {}
}