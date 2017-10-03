import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';

import '../../gallery_api.dart';
import '../requests/password_change_request.dart';
import 'package:server/api/api.dart';

class UserResource extends AIdResource<User> {
  static final Logger _log = new Logger('UserResource');

  final UserModel _userModel;
  UserResource(this._userModel);

  @override
  Logger get childLogger => _log;

  @override
  AIdBasedModel<User, User> get idModel => _userModel;

  @ApiMethod(method: 'PUT', path: '${GalleryApi.usersPath}/{uuid}/password/')
  Future<VoidMessage> changePassword(String uuid, PasswordChangeRequest pcr) =>
      catchExceptionsAwait(() async {
        await _userModel.changePassword(
            uuid, pcr.currentPassword, pcr.newPassword);
        return new VoidMessage();
      });

  @override
  @ApiMethod(method: 'POST', path: '${GalleryApi.usersPath}/')
  Future<IdResponse> create(User user) => createWithCatch(user);

  @override
  @ApiMethod(method: 'DELETE', path: '${GalleryApi.usersPath}/{uuid}/')
  Future<VoidMessage> delete(String uuid) => deleteWithCatch(uuid);

  @override
  String generateRedirect(String newUuid) =>
      "${dartleryServerContext.apiPrefix}${GalleryApi.usersPath}/$newUuid";

  @override
  @ApiMethod(path: '${GalleryApi.usersPath}/{uuid}/')
  Future<User> getById(String uuid) => getByUuidWithCatch(uuid);

  @ApiMethod(path: 'current_user/')
  Future<User> getMe() => catchExceptionsAwait(() => _userModel.getMe());

  @override
  @ApiMethod(method: 'PUT', path: '${GalleryApi.usersPath}/{uuid}/')
  Future<IdResponse> update(String uuid, User user) =>
      updateWithCatch(uuid, user);
}
