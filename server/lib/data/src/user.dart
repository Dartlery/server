import 'package:dartlery_shared/global.dart';
import 'package:rpc/rpc.dart';

import 'package:server/data/data.dart';

@ApiMessage(includeSuper: true)
class User extends AUser {
  User();
  User.copy(dynamic o) : super.copy(o);

  bool evaluateType(String needed) {
    return new UserPrivilegeSet().evaluate(needed, this.type);
  }
}
