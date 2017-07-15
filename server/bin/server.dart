import 'package:dartlery_shared/tools.dart';
import 'dart:io';
import 'dart:async';
import 'package:dartlery/services/background_service.dart';
import 'dart:isolate';
import 'package:di/di.dart';
import 'package:args/args.dart';
import 'package:dartlery/server.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart'
    as server_logging;
import 'package:dartlery/model/model.dart';

Future<Null> main(List<String> args) async {
  // Add a simple log handler to log information to a server side file.
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen(new server_logging.LogPrintHandler());
  //final Logger _log = new Logger("server.main()");

  final ArgParser parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8080')
    ..addOption('ip', abbr: 'i', defaultsTo: '0.0.0.0')
    ..addOption('mongo', abbr: 'm', defaultsTo: '');



  final ArgResults result = parser.parse(args);

  final int port = int.parse(result['port'], onError: (String val) {
    stdout.writeln('Could not parse port value "$val" into a number.');
    exit(1);
  });

  String connectionString = result['mongo'];
  if(isNullOrWhitespace(connectionString)) {
    connectionString =  Platform.environment["DARTLERY_MONGO"];
  }

  if(isNullOrWhitespace(connectionString)) {
    connectionString =  "mongodb://localhost:27017/dartlery";
  }


  final String ip = result['ip'];

  final Server server = Server.createInstance(connectionString);
  server.start(ip, port);

  // Now we start the thread for the background service
  await Isolate.spawn(startBackgroundIsolate, connectionString);
}

void startBackgroundIsolate(String connectionString) {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen(new server_logging.LogPrintHandler());

  final ModuleInjector injector = createModelModuleInjector(connectionString);
  final BackgroundService service = injector.get(BackgroundService);
  service.start();
}
