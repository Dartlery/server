import 'package:tools/tools.dart';
import 'dart:async';
import 'package:args/args.dart';
import 'package:dartlery/model/model.dart';
import 'package:di/di.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart'
    as server_logging;

Future<Null> main(List<String> args) async {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen(new server_logging.LogPrintHandler());
  final Logger _log = new Logger("server.main()");

  final ArgParser parser = new ArgParser();
  parser.addOption("sourceType", abbr: 't', allowed: ["shimmie", "path"]);
  parser.addOption("path", abbr: 'p');
  parser.addOption("start");
  parser.addOption("stopOnError", defaultsTo: "true");
  parser.addOption("sourceDbHost");
  parser.addOption("sourceDb");
  parser.addOption("sourceDbUser");
  parser.addOption("sourceDbPassword");
  parser.addOption('mongo',
      abbr: 'm', defaultsTo: '"mongodb://localhost:27017/dartlery"');

  final ArgResults argResults = parser.parse(args);

  // Currently only supports importing from shimmie. Yay!

  // TODO: Set up a function for loading settings data
  final String connectionString = argResults["mongo"];

  final ModuleInjector parentInjector =
      createModelModuleInjector(connectionString);

  final ImportModel importModel = parentInjector.get(ImportModel);

  final bool stopOnError = argResults["stopOnError"].toLowerCase() != 'false';

  switch (argResults["sourceType"]) {
    case "shimmie":
      if (isNullOrWhitespace(argResults["path"]))
        throw new Exception("path is required");
      if (isNullOrWhitespace(argResults["sourceDbHost"]))
        throw new Exception("sourceDbHost is required");
      if (isNullOrWhitespace(argResults["sourceDb"]))
        throw new Exception("sourceDb is required");
      if (isNullOrWhitespace(argResults["sourceDbUser"]))
        throw new Exception("sourceDbUser is required");
      if (isNullOrWhitespace(argResults["sourceDbPassword"]))
        throw new Exception("sourceDbPassword is required");

      if (isNotNullOrWhitespace(argResults["start"])) {
        final int start = int.parse(argResults["start"]);
        await importModel.importFromShimmie(
            argResults["path"],
            argResults["sourceDbHost"],
            argResults["sourceDbUser"],
            argResults["sourceDbPassword"],
            argResults["sourceDb"],
            stopOnError: stopOnError,
            startAt: start);
      } else {
        await importModel.importFromShimmie(
            argResults["path"],
            argResults["sourceDbHost"],
            argResults["sourceDbUser"],
            argResults["sourceDbPassword"],
            argResults["sourceDb"],
            stopOnError: stopOnError);
      }
      break;
    case "path":
      if (isNullOrWhitespace(argResults["path"]))
        throw new Exception("Path is required");
      await importModel.importFromPath(argResults["path"],
          interpretFileNames: true, stopOnError: stopOnError);
  }

  //await importModel.importFromPath(r"\\darkholme\rand\importTest", interpretShimmieNames: true, stopOnError: true);

  _log.info("Process is over!");
}
