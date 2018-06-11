import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:args/args.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery/services/background_service.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dice/dice.dart';
import 'package:dartlery/extensions/extensions.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart'
    as server_logging;

import 'package:dartlery/data_sources/data_sources.dart';
//import 'server.template.dart' as ng;



Future<Null> main(List<String> args) async {
  // Add a simple log handler to log information to a server side file.
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen(new server_logging.LogPrintHandler());
  final Logger _log = new Logger("server.main()");

  final ArgParser parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8080')
    ..addOption('ip', abbr: 'i', defaultsTo: '0.0.0.0')
    ..addOption('mongo', abbr: 'm', defaultsTo: '')
    ..addOption('data', abbr: 'd', defaultsTo: '')
    ..addOption('log', abbr: 'l');

  final ArgResults result = parser.parse(args);

  //ng.initReflector();

  String logLevelString = result["log"];
  if (isNullOrWhitespace(logLevelString)) {
    logLevelString = Platform.environment["DARTLERY_LOG"];
  }
  if (isNotNullOrWhitespace(logLevelString)) {
    for (Level l in Level.LEVELS) {
      if (logLevelString.toLowerCase() == l.name.toLowerCase()) {
        Logger.root.level = l;
        _log.config("Log level set to ${l.name}");
        break;
      }
    }
  }

  final int port = int.tryParse(result['port']);
  if(port==null) {
    _log.severe('Could not parse port value "${result['port']}" into a number.');
    exit(1);
  }

  String connectionString = result['mongo'];
  if (isNullOrWhitespace(connectionString)) {
    connectionString = Platform.environment["DARTLERY_MONGO"];
  }

  if (isNullOrWhitespace(connectionString)) {
    connectionString = "mongodb://localhost:27017/dartlery";
  }

  final String ip = result['ip'];

  String dataPath = result['data'];
  if (isNullOrWhitespace(dataPath)) {
    dataPath = null;
  }

  final Server server =
      Server.createInstance(connectionString, dataPath: dataPath);
  server.start(ip, port);

  // Now we start the thread for the background service
  await Isolate.spawn(
      startBackgroundIsolate,
      new BackgroundConfig()
        ..loggingLevel = Logger.root.level
        ..connectionString = connectionString);
}

void startBackgroundIsolate(BackgroundConfig config) {
  Logger.root.level = config.loggingLevel;
  Logger.root.onRecord.listen(new server_logging.LogPrintHandler());



  final Injector injector = createInjector(config.connectionString);

  final DbLoggingHandler dbLoggingHandler =
      new DbLoggingHandler(injector.get(ALogDataSource));
  Logger.root.onRecord.listen(dbLoggingHandler);

  final BackgroundService service = injector.get(BackgroundService);
  service.start();
}

Injector createInjector(String connectionString) =>
new Injector.fromModules([new ModelModule(), new DataSourceModule(connectionString), new ExtensionsModule()]);


class BackgroundConfig {
  String connectionString;
  Level loggingLevel;
}
