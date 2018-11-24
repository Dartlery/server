import 'package:dartlery_shared/tools.dart';
import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:dartlery/model/model.dart';
import 'package:dice/dice.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart'
    as server_logging;
import 'package:options_file/options_file.dart';
import 'package:dartlery/extensions/extensions.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/data/data.dart';
<<<<<<< HEAD
import 'reprocess.template.dart' as ng;
=======
import 'package:dartlery/server.dart';
>>>>>>> master

Future<Null> main(List<String> args) async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen(new server_logging.LogPrintHandler());
  final Logger _log = new Logger("server.main()");

  final ArgParser parser = new ArgParser();
  parser.addOption("mimeType", abbr: 'm');
  final ArgResults argResults = parser.parse(args);

  ng.initReflector();


  // TODO: Set up a function for loading settings data
  final DatabaseInfo dbInfo = DatabaseInfo.prepare(argResults);

<<<<<<< HEAD
  final Injector parentInjector =
  new Injector.fromModules([new ModelModule(), new DataSourceModule(connectionString), new ExtensionsModule()]);
=======
  final ModuleInjector parentInjector =
      createModelModuleInjector(dbInfo);

  final ModuleInjector extensionInjector =
      instantiateExtensions(parentInjector);
>>>>>>> master

  final ItemReprocessExtension reprocessExtension =
  parentInjector.get(ItemReprocessExtension);
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
