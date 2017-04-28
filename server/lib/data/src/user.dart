import 'package:dartlery_shared/global.dart';
import 'package:rpc/rpc.dart';

import 'a_id_data.dart';

@ApiMessage(includeSuper: true)
class User extends AIdData {
  String password;
  String name;
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
