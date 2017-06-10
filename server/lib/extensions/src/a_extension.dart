import 'dart:async';
import 'package:dartlery/data/data.dart';

abstract class AExtension {
  String get extensionId;

  Future<Null> onCreatingItem(Item item) async {}
  Future<Null> onDeletingItem(String itemId) async {}
  Future<Null> onBackgroundCycle(BackgroundQueueItem item) async {}
}
