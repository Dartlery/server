import 'dart:io';

import 'package:logging/logging.dart';
import 'package:rest_server/rest_server.dart';
import 'package:sqljocky/sqljocky.dart' as mysql;

import 'package:dartlery_server/dartlery.dart';
import 'package:dartlery_server/resources/resources.dart';
import 'package:dartlery_server/model/model.dart';





void main() {
  
  
  Logger.root.level = Level.CONFIG;
  Logger.root.onRecord.listen(RecordLog);
  
  final Logger _log = new Logger('main');
  
  try {
  
    loadConfigFile();
    
    SettingsModel settings = new SettingsModel();
    
    RestServer rest = new RestServer();
    
    rest.accessControlAllowOrigin = "*";
    rest.accessControlAllowHeaders = "${HttpHeaders.CONTENT_TYPE},${HttpHeaders.RANGE}";
    rest.accessControlExposeHeaders = HttpHeaders.CONTENT_RANGE;
    
    rest.addDefaultAvailableContentType(new ContentType("application", "json", charset: "utf-8"));
  
    mysql.ConnectionPool pool = getConnectionPool();
    
    rest.addResource(new FilesResource(pool));
    rest.addResource(new TagsResource(pool));
    rest.addResource(new TagGroupsResource(pool));
    rest.addResource(new StaticResource());
    rest.addResource(new ImportResource(pool));
    
    rest.start(address: new InternetAddress("127.0.0.1"), port: 8888);
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

mysql.ConnectionPool getConnectionPool() {
  return new mysql.ConnectionPool(host: dbSettings["host"], port: dbSettings["port"],
          user: dbSettings["user"],password: dbSettings["password"], db: dbSettings["db"], max: 5);
}
