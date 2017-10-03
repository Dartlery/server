import 'package:tools/tools.dart';

/// Provides the various values of available user privileges, and helper functions to aid in comparing them/
class UserPrivilegeSet extends APrivilegeSet {
  static const String normal = "normal";
  static const String moderator = "moderator";

  UserPrivilegeSet() : super(<String>[normal, moderator]);
}
