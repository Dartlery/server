import 'dart:async';

import 'package:dartlery_shared/global.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';

import 'a_mongo_id_data_source.dart';
import 'constants.dart';

import 'package:dice/dice.dart';
@Injectable()
class MongoUserDataSource extends AMongoIdDataSource<User>
    with AUserDataSource {
  static final Logger _log = new Logger('MongoUserDataSource');
  @override
  Logger get childLogger => _log;

  static const String typeField = "type";
  static const String emailField = "email";
  static const String passwordField = "password";

  @inject
  MongoUserDataSource(MongoDbConnectionPool pool) : super(pool);

  @override
  Future<User> createObject(Map data) async {
    final User output = new User();
    AMongoIdDataSource.setIdForData(output, data);
    output.name = data[nameField];
    output.type = data[typeField];
    return output;
  }

  @override
  Future<List<User>> getAdmins() {
    return this.getFromDb(where.eq(typeField, UserPrivilege.admin));
  }

  @override
  Future<DbCollection> getCollection(MongoDatabase con) =>
      con.getUsersCollection();

  @override
  Future<Option<String>> getPasswordHash(String username) async {
    final SelectorBuilder selector = where.eq(idField, username);
    final Option<Map> data = await genericFindOne(selector);
    return data.map((dynamic user) {
      if (user.containsKey(passwordField)) return user[passwordField];
    });
  }

  @override
  Future<Null> setPassword(String uuid, String password) async {
    final SelectorBuilder selector = where.eq(idField, uuid);

    final ModifierBuilder modifier = modify.set(passwordField, password);
    await genericUpdate(selector, modifier, multiUpdate: false);
  }

  @override
  void updateMap(AIdData user, Map data) {
    if(user is User) {
      super.updateMap(user, data);
      data[nameField] = user.name;
      data[typeField] = user.type;
    }
  }
}
