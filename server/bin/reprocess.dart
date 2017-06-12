import 'package:dartlery_shared/tools.dart';
import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:dartlery/model/model.dart';
import 'package:di/di.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart'
    as server_logging;
import 'package:options_file/options_file.dart';
import 'package:dartlery/extensions/extensions.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/data/data.dart';

Future<Null> main(List<String> args) async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen(new server_logging.LogPrintHandler());
  final Logger _log = new Logger("server.main()");

  final ArgParser parser = new ArgParser();
  parser.addOption("mimeType", abbr: 'm');
  final ArgResults argResults = parser.parse(args);

  // TODO: Set up a function for loading settings data
  String connectionString = "mongodb://localhost:27017/dartlery";

  try {
    final OptionsFile optionsFile = new OptionsFile('server.options');
    connectionString =
        optionsFile.getString("connection_string", connectionString);
  } on FileSystemException catch (e) {
    _log.info("server.options not found, using all default settings", e);
  }

  final ModuleInjector parentInjector =
      createModelModuleInjector(connectionString);

  final ModuleInjector extensionInjector =
      instantiateExtensions(parentInjector);

  final ItemReprocessExtension reprocessExtension =
      extensionInjector.get(ItemReprocessExtension);
  final AItemDataSource _itemDataSource = parentInjector.get(AItemDataSource);

  final String type = argResults["mimeType"];

  if (isNullOrWhitespace(type)) {
    throw new Exception("mimeType is required");
  }

  final Stream<Item> itemStream = await _itemDataSource.streamByMimeType(type);

  await for (Item item in itemStream) {
    _log.info("Re-processing item ${item.id}");
    final BackgroundQueueItem queueItem = new BackgroundQueueItem();
    queueItem.data = item.id;
    queueItem.extensionId = reprocessExtension.extensionId;
    await reprocessExtension.onBackgroundCycle(queueItem);
  }

  _log.info("Process is over!");
}
