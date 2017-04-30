import 'dart:io';
import 'package:dartlery/server.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart'
as server_logging;
import 'package:options_file/options_file.dart';
import 'package:di/di.dart';
import 'package:dartlery/model/model.dart';
import 'package:args/args.dart';


void main(List<String> args) {
//  var parser = new argsLib.ArgParser()
//    ..addOption('port', abbr: 'p', defaultsTo: '8080');
//
//  var result = parser.parse(args);
//
//  var port = int.parse(result['port'], onError: (val) {
//    stdout.writeln('Could not parse port value "$val" into a number.');
//    exit(1);
//  });
//
  // Add a simple log handler to log information to a server side file.
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen(new server_logging.LogPrintHandler());
  final Logger _log = new Logger("server.main()");

  final ArgParser parser = new ArgParser();
  parser.addOption("connectionString", abbr: 'cs');
  parser.addOption("sourceType", abbr: 't', allowed: ["shimmie"]);
  final ArgResults argResults = parser.parse(args);


  // Currently only supports importing from shimmie. Yay!



    // TODO: Set up a function for loading settings data
    String connectionString = "mongodb://localhost:27017/dartalog";

    try {
      final OptionsFile optionsFile = new OptionsFile('server.options');
      connectionString =
          optionsFile.getString("connection_string", connectionString);
    } on FileSystemException catch (e) {
      _log.info("server.options not found, using all default settings", e);
    }

    final ModuleInjector parentInjector =
    createModelModuleInjector(connectionString);

    final ItemModel itemModel = parentInjector.get(ItemModel);



}