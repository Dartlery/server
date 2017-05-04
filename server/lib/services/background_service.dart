import 'dart:async';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:logging/logging.dart';
import 'package:dartlery/data/data.dart';
import 'package:option/option.dart';
import 'package:dartlery/services/plugin_service.dart';
import 'package:dartlery_shared/tools.dart';

class BackgroundService {
  static final Logger _log = new Logger('BackgroundService');

  bool _stop = false;
  final ABackgroundQueueDataSource _backgroundQueueDataSource;
  final PluginService _pluginService;

  BackgroundService(this._backgroundQueueDataSource, this._pluginService);

  void start() {
    _log.info("Starting background service");
    Timer.run(() {
      _backgroundThread();
    });
  }

  void stop() {
    _log.info("Stopping background service");
    _stop = true;
  }

  Future<Null> _backgroundThread() async {
    while(!_stop) {
    try {
      _log.info("Starting background service cycle");
      Option<BackgroundQueueItem> nextItem = await _backgroundQueueDataSource.getNextItem();

      while(nextItem.isNotEmpty) {
        try {
          await _pluginService.triggerBackgroundServiceCycle(nextItem.first);
        } finally {
          await _backgroundQueueDataSource.deleteItem(nextItem.first.id);
        }
        nextItem = await _backgroundQueueDataSource.getNextItem();
      }
    } catch(e,st) {
      _log.severe(e, st);
    } finally {
      await wait(milliseconds: 60000);
    }
    }

  }


}