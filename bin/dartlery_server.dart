import 'dart:io';

import 'package:logging/logging.dart';
import 'package:rest_dart/rest_dart.dart';

import 'package:dartlery_server/dartlery.dart';
import 'package:dartlery_server/resources/resources.dart';





void main() {
  
  
  Logger.root.level = Level.CONFIG;
  Logger.root.onRecord.listen(RecordLog);
  
  final Logger _log = new Logger('main');
  
  try {
  
    loadConfigFile();
    
    RestServer rest = new RestServer();
    
    rest.addDefaultAvailableContentType(new ContentType("application", "json", charset: "utf-8"));
  
    rest.addResource(new FilesResource());
    rest.addResource(new StaticResource());
    rest.addResource(new ImportResource());
    
    rest.start(port: 8888);
  } catch(e,st) {
    _log.severe("Error while starting Dartlery server",e,st);
  }
  
}

void RecordLog(LogRecord rec) {
  print('${rec.time}: ${rec.level.name}: (${rec.loggerName}) ${rec.message}');
  if(rec.stackTrace!=null) {
    print('${rec.time}: ${rec.level.name}: (${rec.loggerName}) ${rec.stackTrace.toString()}');
  }
}

