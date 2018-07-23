import 'package:dartlery_shared/global.dart';
import 'package:rpc/rpc.dart';
import 'package:orm/orm.dart';

import 'a_id_data.dart';

@ApiMessage(includeSuper: true)
@DbStorage("users")
@DbIndex("userIdIndex", const {AIdData.idField: Direction.ascending}, unique: true)
class User extends AIdData {
  static const String passwordField = "password", nameField = "name", typeField = "type";

  @DbField(name: User.passwordField)
  String password;
  @DbField(name: User.nameField)
  String name;
  @DbField(name: User.typeField)
  String type;

  User();

  User.copy(dynamic o) : super.copy(o) {
    this.name = o.name;
    this.type = o.type;
    if (o.password == null)
      this.password = "";
    else
      this.password = o.password;
  }

  bool evaluateType(String needed) {
    return UserPrivilege.evaluate(needed, this.type);
  }
}
