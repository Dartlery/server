import 'dart:async';

import 'package:dartlery_shared/global.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';
import 'package:tools/tools.dart';
import '../mongo.dart';
import 'package:server/data_sources/mongo/mongo.dart';
import 'package:server/data_sources/interfaces.dart';
import 'package:server/data_sources/data_sources.dart';

class MongoUserDataSource extends AMongoIdDataSource<User>
    with AUserDataSource<User> {
  static final Logger _log = new Logger('MongoUserDataSource');
  @override
  Logger get childLogger => _log;



  MongoUserDataSource(MongoDbConnectionPool pool) : super(pool);

  @override
  Future<User> createObject(Map data) async {
    final User output = new User();
    AMongoIdDataSource.setIdForData(output, data);
    output.name = data[nameField];
    output.type = data[User.typeField];
    return output;
  }

  @override
  Future<List<User>> getAdmins() {
    return this.getFromDb(where.eq(User.typeField, APrivilegeSet.admin));
  }

  @override
  Future<Option<String>> getPasswordHash(String username) async {
    final SelectorBuilder selector = where.eq(idField, username);
    final Option<Map> data = await genericFindOne(selector);
    return data.map((Map user) {
      if (user.containsKey(User.passwordField)) return user[User.passwordField];
    });
  }

  @override
  Future<Null> setPassword(String uuid, String password) async {
    final SelectorBuilder selector = where.eq(idField, uuid);

    final ModifierBuilder modifier = modify.set(User.passwordField, password);
    await genericUpdate(selector, modifier, multiUpdate: false);
  }

  @override
  void updateMap(User user, Map data) {
    super.updateMap(user, data);
    data[nameField] = user.name;
    data[User.typeField] = user.type;
  }
}
