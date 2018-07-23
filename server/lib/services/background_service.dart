import 'dart:async';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:logging/logging.dart';
import 'package:dartlery/data/data.dart';
import 'package:option/option.dart';
import 'package:dartlery/extensions/extensions.dart';
import 'package:dartlery_shared/tools.dart';
import 'extension_service.dart';

class BackgroundService {
  static final Logger _log = new Logger('BackgroundService');

  static bool get stopping => _stop;

  static bool _stop = false;

  final ABackgroundQueueDataSource _backgroundQueueDataSource;
  final ExtensionService _extensionService;

  BackgroundService(this._backgroundQueueDataSource, this._extensionService);

  Future<Null> start() {
    if(_stop)
      throw new Exception("Stop has been called, cannot start again");
    _log.info("Starting background service");
    return _backgroundThread();
  }

  final Completer<Null> _stopCompleter = new Completer<Null>();

  Future<Null> stop() {
    _log.info("Stopping background service");
    _stop = true;

    if((waitTimer?.isActive)??false) {
      _log.info("Background thread sleeping, killing sleep");
      waitTimer?.cancel();
      completer?.complete();
    }

    return _stopCompleter.future;
  }

  Completer<Null> completer;
  Timer waitTimer;

  Future<Null> _backgroundThread() async {
    _log.finest("_backgroundThread start");
    while (!_stop) {
      try {
        _log.fine("Starting background service cycle");
        Option<BackgroundQueueItem> nextItem =
            await _backgroundQueueDataSource.getNextItem();

        while (nextItem.isNotEmpty) {
          try {
            await _extensionService
                .triggerBackgroundServiceCycle(nextItem.first);
          } finally {
            await _backgroundQueueDataSource.deleteItem(nextItem.first.id);
          }
          if(_stop) {
            break;
          }
          nextItem = await _backgroundQueueDataSource.getNextItem();
        }
      } catch (e, st) {
        _log.severe(e, st);
      } finally {
        if(!_stop) {
          completer = new Completer<Null>();
          waitTimer = new Timer(new Duration(milliseconds: 10000), () {
            completer.complete();
            waitTimer = null;
            completer = null;
          });
          await completer.future;
        }
      }
    }
    if (_stop) {
      _log.info("End of background thread loop reached normally");
    } else {
      _log.warning("End of background thread loop reached abruptly");
    }
    _stopCompleter.complete();
    _log.finest("_backgroundThread end");
  }
}
