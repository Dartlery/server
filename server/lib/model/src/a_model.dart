import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:orm/orm.dart';
import 'package:shelf_auth/shelf_auth.dart';


abstract class AModel {
  static Principal _authenticationOverride;

  final DatabaseContext _db;

  AModel(this._db);

  @protected
  String get currentUserId => userPrincipal?.name??"";
  // TODO: Get this not to be static so that it's carried along with the server instance.

  @protected
  DatabaseContext get db => _db;
  @protected
  String get defaultCreatePrivilegeRequirement =>
      defaultWritePrivilegeRequirement;

  @protected
  String get defaultDeletePrivilegeRequirement =>
      defaultWritePrivilegeRequirement;

  @protected
  String get defaultPrivilegeRequirement => UserPrivilege.admin;
  @protected
  String get defaultReadPrivilegeRequirement => defaultPrivilegeRequirement;
  @protected
  String get defaultUpdatePrivilegeRequirement =>
      defaultWritePrivilegeRequirement;
  @protected
  String get defaultWritePrivilegeRequirement => defaultPrivilegeRequirement;
  @protected
  Logger get loggerImpl;
  @protected
  bool get userAuthenticated {
    return userPrincipal!=null;
  }

  @protected
  Principal get userPrincipal {
    if (_authenticationOverride == null) {
      return authenticatedContext()
          .map((AuthenticatedContext<Principal> context) => context.principal).getOrDefault(null);
    } else {
      return _authenticationOverride;
    }
  }

  @protected
  Future<User> getCurrentUser() async {
    if(userPrincipal==null)
      throw new UnauthorizedException("Please log in");
    try {
      return await db.getOneByQuery(
          User, select..equals(User.nameField, userPrincipal.name));
    } on NotFoundException {
      throw new UnauthorizedException("User not found");
    }
  }

  @protected
  Future<bool> userHasPrivilege(String userType) async {
    if (userType == UserPrivilege.none)
      return true; //None is equivalent to not being logged in, or logged in as a user with no privileges
    final User user = await getCurrentUser();
    return UserPrivilege.evaluate(userType, user.type);
  }

  @protected
  Future<bool> validateCreatePrivilegeRequirement() =>
      validateUserPrivilege(defaultCreatePrivilegeRequirement);

  @protected
  Future<Null> validateCreatePrivileges() async {
    if (!userAuthenticated) {
      throw new UnauthorizedException();
    }
    await validateCreatePrivilegeRequirement();
  }

  @protected
  Future<bool> validateDefaultPrivilegeRequirement() =>
      validateUserPrivilege(defaultPrivilegeRequirement);

  @protected
  Future<bool> validateDeletePrivilegeRequirement() =>
      validateUserPrivilege(defaultDeletePrivilegeRequirement);

  @protected
  Future<Null> validateDeletePrivileges([String id]) async {
    if (!userAuthenticated) {
      throw new UnauthorizedException();
    }
    await validateDeletePrivilegeRequirement();
  }

  @protected
  Future<Null> validateGetPrivileges() async {
    await validateReadPrivilegeRequirement();
  }

  @protected
  Future<bool> validateReadPrivilegeRequirement() =>
      validateUserPrivilege(defaultReadPrivilegeRequirement);

  @protected
  Future<bool> validateUpdatePrivilegeRequirement() =>
      validateUserPrivilege(defaultUpdatePrivilegeRequirement);

  @protected
  Future<Null> validateUpdatePrivileges(String uuid) async {
    if (!userAuthenticated) {
      throw new UnauthorizedException();
    }
    await validateUpdatePrivilegeRequirement();
  }

  @protected
  Future<bool> validateUserPrivilege(String privilege) async {
    if (await userHasPrivilege(privilege)) return true;
    throw new ForbiddenException("$privilege required");
  }

  /// Clears out all current user overrides, even an override of "un-authenticated".
  @visibleForTesting
  static void clearCurrentUserOverride() => _authenticationOverride = null;

  /// Manually sets the current logged-in (or not logged-in) user.
  @visibleForTesting
  static void overrideCurrentUser(String uuid) {
    if (isNullOrWhitespace(uuid)) {
      _authenticationOverride = null;
    } else {
      _authenticationOverride = new Principal(uuid);
    }
  }
}
