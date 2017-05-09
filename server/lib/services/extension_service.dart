import 'dart:async';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/extensions/extensions.dart';

class ExtensionService {
  final Map<String,AExtension> _extensions = <String,AExtension>{};

  void addPlugin(AExtension extension) {
    _extensions[extension.extensionId] = extension;
  }

  Future<Null> sendCreatingItem(Item item) => Future.forEach(_extensions.values, (AExtension extension) => extension.onCreatingItem(item));
  Future<Null> sendDeletingItem(String itemId) => Future.forEach(_extensions.values, (AExtension extension) => extension.onDeletingItem(itemId));

  Future<Null> triggerBackgroundServiceCycle(BackgroundQueueItem item) async {
    if(!_extensions.containsKey(item.extensionId))
      return;
    await _extensions[item.extensionId].onBackgroundCycle(item);
  }

}
