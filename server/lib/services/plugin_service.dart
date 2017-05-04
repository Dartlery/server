import 'dart:async';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/plugins/plugins.dart';

class PluginService {
  final Map<String,APlugin> _plugins = <String,APlugin>{};

  void addPlugin(APlugin plugin) {
    _plugins[plugin.pluginId] = plugin;
  }

  Future<Null> sendCreatingItem(Item item) => Future.forEach(_plugins.values, (APlugin plugin) => plugin.onCreatingItem(item));

  Future<Null> triggerBackgroundServiceCycle(BackgroundQueueItem item) async {
    if(!_plugins.containsKey(item.pluginId))
      return;
    await _plugins[item.pluginId].onBackgroundCycle(item);
  }

}
