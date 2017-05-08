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

Future<Null> main(List<String> args) async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen(new server_logging.LogPrintHandler());
  final Logger _log = new Logger("server.main()");

  final ArgParser parser = new ArgParser();
  parser.addOption("sourceType", abbr: 't', allowed: ["shimmie", "path"]);
  parser.addOption("path", abbr: 'p');
  parser.addOption("start");
  final ArgResults argResults = parser.parse(args);

  // Currently only supports importing from shimmie. Yay!

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

  final ImportModel importModel = parentInjector.get(ImportModel);

  switch (argResults["sourceType"]) {
    case "shimmie":
      if (StringTools.isNullOrWhitespace(argResults["path"]))
        throw new Exception("path is required");
      if (StringTools.isNotNullOrWhitespace(argResults["start"])) {
        final int start = int.parse(argResults["start"]);
        await importModel.importFromShimmie(argResults["path"],
            stopOnError: true, startAt: start);
      } else {
        await importModel.importFromShimmie(argResults["path"],
            stopOnError: true);
      }
      break;
    case "path":
      if (StringTools.isNullOrWhitespace(argResults["path"]))
        throw new Exception("Path is required");
      await importModel.importFromPath(argResults["path"],
          interpretShimmieNames: true, stopOnError: true);
  }

  //await importModel.importFromPath(r"\\darkholme\rand\importTest", interpretShimmieNames: true, stopOnError: true);

  _log.info("Process is over!");
}
