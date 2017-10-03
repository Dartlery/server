import 'dart:async';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:logging/logging.dart';
import 'package:dartlery/data/data.dart';
import 'package:option/option.dart';
import 'package:dartlery/extensions/extensions.dart';
import 'package:tools/tools.dart';
import 'extension_service.dart';
import 'package:server/server.dart';

class BackgroundService extends ABackgroundService {
  static final Logger _log = new Logger('BackgroundService');

  final ABackgroundQueueDataSource _backgroundQueueDataSource;
  final ExtensionService _extensionService;

  BackgroundService(this._backgroundQueueDataSource, this._extensionService);

  @override
  Future<Null> doWork() async {
    _log.info("Starting background service cycle");
    Option<BackgroundQueueItem> nextItem =
    await _backgroundQueueDataSource.getNextItem();

    while (nextItem.isNotEmpty) {
      try {
        await _extensionService
            .triggerBackgroundServiceCycle(nextItem.first);
      } finally {
        await _backgroundQueueDataSource.deleteItem(nextItem.first.id);
      }
      nextItem = await _backgroundQueueDataSource.getNextItem();
    }
  }


}
