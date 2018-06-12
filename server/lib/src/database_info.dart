import 'dart:io';
import 'package:args/args.dart';
import 'package:dartlery_shared/tools.dart';

abstract class DatabaseInfo {
  static DatabaseInfo prepare(ArgResults data) {
    if (isNotNullOrWhitespace(data['mongo'])) {
      return  new MongoDatabaseInfo(data['mongo']);
    } else if(isNotNullOrWhitespace(Platform.environment["DARTLERY_MONGO"])) {
      return  new MongoDatabaseInfo(Platform.environment["DARTLERY_MONGO"]);
    } else if(isNotNullOrWhitespace(data["postgresHost"])) {
      return new PostgresDatabaseInfo(data["postgresHost"], int.parse(data["postgresPort"]), data["postgresDatabase"],
          username:  data["postgresUsername"], password:  data["postgresPassword"], useSSL:  data["postgresSsl"]?.toLowerCase()=="true");
    }


    throw new Exception("Couldn't determine database type");
  }
}

class MongoDatabaseInfo extends DatabaseInfo {
  final String connectionString;
  MongoDatabaseInfo(this.connectionString);
}

class PostgresDatabaseInfo extends DatabaseInfo {
  String host;
  int port;
  String databaseName;
  String username;
  String password;
  bool useSSL;

  PostgresDatabaseInfo(this.host, this.port, this.databaseName,
      {this.username, this.password, this.useSSL: false});
}