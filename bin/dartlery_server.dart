import 'dart:io';

import 'package:logging/logging.dart';
import 'package:rest_dart/rest_dart.dart';

import 'package:dartlery_server/dartlery.dart';
import 'package:dartlery_server/resources/resources.dart';

import 'package:sqljocky/sqljocky.dart' as mysql;

void main() {
  
  Logger.root.level = Level.CONFIG;
  Logger.root.onRecord.listen(RecordLog);

  
  mysql.ConnectionPool pool  = 
      new mysql.ConnectionPool(host: 'localhost', port: 3306,
          user: 'dartlery',password: '', db: 'dartlery', max: 5);
  
  RestServer rest = new RestServer();
  
  rest.AddDefaultContentType(new ContentType("application", "json", charset: "utf-8"));

  rest.AddResource(new FilesResource(pool));
  
  rest.Start();
  
}

void RecordLog(LogRecord rec) {
  print('${rec.time}: ${rec.level.name}: (${rec.loggerName}) ${rec.message}');
}