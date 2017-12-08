import 'package:dartlery_shared/global.dart';
import 'package:rpc/rpc.dart';
import 'package:server/data_sources/data_sources.dart';
import 'package:server/data/data.dart';

@ApiMessage(includeSuper: true)
class User extends AUser {
  static const String typeField = "type";
  static const String emailField = "email";
  static const String passwordField = "password";

  User();
  User.copy(dynamic o) : super.copy(o);

  bool evaluateType(String needed) {
    return new UserPrivilegeSet().evaluate(needed, this.type);
  }
}
