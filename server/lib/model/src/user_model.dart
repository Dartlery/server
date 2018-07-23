import 'dart:async';
import 'package:crypt/crypt.dart';
import 'package:logging/logging.dart';
import 'package:option/option.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:orm/orm.dart';
import 'a_id_based_model.dart';
import 'a_model.dart';

class UserModel extends AIdBasedModel<User, String> {
  static final Logger _log = new Logger('UserModel');

  UserModel(DatabaseContext db) : super(db);

  @override
  Logger get loggerImpl => _log;

  @override
  AUserDataSource get dataSource => null;

  @override
  String get defaultReadPrivilegeRequirement => UserPrivilege.moderator;

  @override
  Future<Null> validateFields(User user, Map<String, String> fieldErrors,
      {String existingId: null}) async {
    await super.validateFields(user, fieldErrors);

    if (isNullOrWhitespace(user.name)) {
      fieldErrors["name"] = "Required";
    }

    if (isNullOrWhitespace(existingId) || !isNullOrWhitespace(user.password)) {
      _validatePassword(fieldErrors, user.password);
    }
    if (isNullOrWhitespace(user.type)) {
      fieldErrors["type"] = "Required";
    } else {
      if (!UserPrivilege.values.contains(user.type))
        fieldErrors["type"] = "Invalid";
    }
  }

  void _validatePassword(Map<String, String> fieldErrors, String password) {
    if (isNullOrWhitespace(password)) {
      fieldErrors["password"] = "Required";
    } else if (password.length < 8) {
      //TODO: Additional restrictions? Keep them sane.
      fieldErrors["password"] = "Must be at least 8 digits long";
    }
  }

  Future<User> getMe() async {
    if (!userAuthenticated) throw new UnauthorizedException();

    try {
      final User output = await _getUser(currentUserId);
      return output;
    } on NotFoundException {
      throw new Exception("Authenticated user not present in database");
    }
  }

  Future<String> createUserWith(String username, String password, String type,
      {bool bypassAuthentication: false}) async {
    final User newUser = new User();
    newUser.id = username;
    newUser.name = username;
    newUser.password = password;
    newUser.type = type;
    return await create(newUser, bypassAuthentication: bypassAuthentication);
  }

  @override
  Future<String> create(User user,
      {List<String> privileges, bool bypassAuthentication: false}) async {
    final String output =
        await super.create(user, bypassAuthentication: bypassAuthentication);

    await _setPassword(output, user.password);

    return output;
  }

  @override
  Future<String> update(String username, User user,
      {bool bypassAuthentication: false}) async {
    final String output = await super
        .update(username, user, bypassAuthentication: bypassAuthentication);

    if (!isNullOrWhitespace(user.password))
      await _setPassword(output, user.password);

    return output;
  }

  @override
  Future<Null> validateUpdatePrivileges(String username) async {
    if (!userAuthenticated) {
      throw new UnauthorizedException();
    }
    // This should allow a user to update their own data
    if (currentUserId != username) {
      await super.validateUpdatePrivileges(username);
    }
  }

  Future<Null> changePassword(
      String username, String currentPassword, String newPassword) async {
    if (!userAuthenticated) {
      throw new UnauthorizedException();
    }

    if (currentUserId != username &&
        !(await userHasPrivilege(UserPrivilege.admin)))
      throw new ForbiddenException(
          "You do not have permission to change another user's password");

    final String userPassword = await _getPasswordHash(username);

    await DataValidationException
        .performValidation((Map<String, String> fieldErrors) async {
      if (isNullOrWhitespace(currentPassword)) {
        fieldErrors["currentPassword"] = "Required";
      } else if (!verifyPassword(userPassword, currentPassword)) {
        fieldErrors["currentPassword"] = "Incorrect";
      }
    });

    await _setPassword(username, newPassword);
  }

  Future<String> _getPasswordHash(String username) async {
    final User user =
        await db.getOneByQuery(User, where..equals(User.nameField, username));
    if (isNullOrWhitespace(user?.password))
      throw new Exception("User $username does not have a current password");
    return user.password;
  }

  Future<User> _getUser(String username) =>
      db.getOneByQuery<User>(User, select..equals(User.nameField, username));

  Future<Null> _setPassword(String username, String newPassword) async {
    await DataValidationException
        .performValidation((Map<String, String> fieldErrors) async {
      _validatePassword(fieldErrors, newPassword);
    });

    final String passwordHash = hashPassword(newPassword);
    final User user = await _getUser(username);
    user.password = passwordHash;
    await db.update(user);
  }

  String hashPassword(String password) {
    return new Crypt.sha256(password).toString();
  }

  bool verifyPassword(String hash, String password) =>
      new Crypt(hash).match(password);
}
