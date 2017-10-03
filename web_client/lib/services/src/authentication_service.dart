import 'dart:async';
import 'package:angular/core.dart';
import 'package:dartlery_shared/global.dart';

import 'package:logging/logging.dart';

import 'api_service.dart';
import 'package:lib_angular/angular.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/api/api.dart' as api;

@Injectable()
class AuthenticationService extends AAuthenticationService<User> {
  static final Logger _log = new Logger("AuthenticationService");

  final ApiService _api;

  AuthenticationService(SettingsService settingsService, this._api)
      : super(settingsService, new UserPrivilegeSet());

  bool get isModerator => hasPrivilege(UserPrivilegeSet.moderator);
  bool get isNormalUser => hasPrivilege(UserPrivilegeSet.normal);

  @override
  Future<User> get currentUser async {
    final api.User apiUser = await _api.users.getMe();
    final User localUser = new User()
      ..id = apiUser.id
      ..name = apiUser.name
      ..privilege = apiUser.type;
    return localUser;
  }
}
