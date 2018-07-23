import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:args/args.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery/services/background_service.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:di/di.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:logging_handlers/server_logging_handlers.dart'
    as server_logging;

import 'package:dartlery/data_sources/data_sources.dart';

Future<Null> main(List<String> args) async {
  // Add a simple log handler to log information to a server side file.
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen(new server_logging.LogPrintHandler());

  final Directory loggingDir = new Directory(loggingFilePath);
  if(!loggingDir.existsSync()) {
    await loggingDir.create(recursive: true);
  }
  final String startTime = new DateTime.now().toString().replaceAll(":","");
  Logger.root.onRecord.listen(new server_logging.SyncFileLoggingHandler(path.join(loggingFilePath,"$startTime.log")));

  final Logger _log = new Logger("server.main()");

  final ArgParser parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8080')
    ..addOption('ip', abbr: 'i', defaultsTo: '0.0.0.0')
    ..addOption('mongo', abbr: 'm', defaultsTo: '')
    ..addOption('postgresHost', defaultsTo: '')
    ..addOption('postgresPort', defaultsTo: '')
    ..addOption('postgresDatabase', defaultsTo: '')
    ..addOption('postgresUsername', defaultsTo: '')
    ..addOption('postgresPassword', defaultsTo: '')
    ..addOption('postgresSsl', defaultsTo: '')
    ..addOption('data', abbr: 'd', defaultsTo: '')
    ..addOption('log', abbr: 'l');

  final ArgResults result = parser.parse(args);

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

  final int port = int.parse(result['port'], onError: (String val) {
    _log.severe('Could not parse port value "$val" into a number.');
    exit(1);
  });


  final DatabaseInfo dbInfo = DatabaseInfo.prepare(result);


  final String ip = result['ip'];

  String dataPath = result['data'];
  if (isNullOrWhitespace(dataPath)) {
    dataPath = null;
  }

  final Server server =
      Server.createInstance(dbInfo, dataPath: dataPath);
  server.start(ip, port);


  // Now we start the thread for the background service
  final ReceivePort receivePort = new ReceivePort();
  final Isolate workerThread = await Isolate.spawn(
      startBackgroundIsolate,
      [new BackgroundConfig()
        ..loggingLevel = Logger.root.level
        ..dbInfo = dbInfo,
      receivePort.sendPort, startTime]);

  SendPort sendPort;
  receivePort.listen((dynamic data) {
    _log.info("Data received: $data");
    if(data=="STOPPED") {
      _log.info("Killing isolate");
      workerThread.kill(priority: Isolate.IMMEDIATE);
      _log.info("Exiting application");
      exit(0);
    } else {
      sendPort = data;
    }
  });


  if(!Platform.isWindows) {
    ProcessSignal.SIGTERM.watch().listen((ProcessSignal signal) {
      shutdown(_log, sendPort, receivePort, server);
    });
  }

  ProcessSignal.SIGINT.watch().listen((ProcessSignal signal) {
    shutdown(_log, sendPort, receivePort, server);
  });

}
Future<Null> shutdown(Logger _log, SendPort sendPort, ReceivePort receivePort, Server server) async {
  _log.info("Shutting down server");
  try {
    _log.info("Requesting server stop");
    await server.stop();
  } catch(e,st) {
    _log.warning("Error while shutting down server", e,st);
  }
  try {
    _log.info("Requesting background thread stop");
    sendPort.send("STOP");
  } catch(e,st) {
    _log.warning("Error while shutting down background process",e,st);
  }
}




void startBackgroundIsolate(List<dynamic> data) {
  final BackgroundConfig config = data[0];
  final SendPort sendPort = data[1];
  final String startTime = data[2];
  final ReceivePort response = new ReceivePort();
  sendPort.send(response.sendPort);

  Logger.root.level = config.loggingLevel;
  Logger.root.onRecord.listen(new server_logging.LogPrintHandler());
  Logger.root.onRecord.listen(new server_logging.SyncFileLoggingHandler(path.join(loggingFilePath,"$startTime.background.log")));

  final Logger _log = new Logger('startBackgroundIsolate');

  final ModuleInjector injector =
      createModelModuleInjector(config.dbInfo);



  final DbLoggingHandler dbLoggingHandler =
      new DbLoggingHandler(injector.get(ALogDataSource));
//  Logger.root.onRecord.listen(dbLoggingHandler);

  final BackgroundService service = injector.get(BackgroundService);
  service.start();

  response.firstWhere((dynamic data) => data=="STOP").then((dynamic data) async {
    _log.info("Message received in isolate: $data");
    await service.stop();
    _log.info("Sending STOPPED signal");
    sendPort.send("STOPPED");
  });

}

class BackgroundConfig {
  DatabaseInfo dbInfo;
  Level loggingLevel;
}
