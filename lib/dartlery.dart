library dartlery;

import 'dart:io' as io;
import 'dart:convert';

import 'package:sqljocky/sqljocky.dart' as mysql;
import 'package:image/image.dart' as image;
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';

import 'package:dartlery_server/model/model.dart';

part 'src/thumbnailer.dart';

Map dbSettings;

void loadConfigFile() {
  io.File config_file = new io.File("config.json");
  if(!config_file.existsSync()) {
    throw new Exception("config.json not found");
    return;
  }
  String config_string = config_file.readAsStringSync();
  var temp = JSON.decode(config_string);
  if(!(temp is Map)) {
    throw new Exception("config.json not formatted properly, must be a map");
  }
  dbSettings = temp;

}

mysql.ConnectionPool getConnectionPool() {
  return new mysql.ConnectionPool(host: dbSettings["host"], port: dbSettings["port"],
          user: dbSettings["user"],password: dbSettings["password"], db: dbSettings["db"], max: 5);
}