import 'dart:async';
import 'dart:io';

import 'package:dartlery_shared/global.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/data_sources/mongo/mongo.dart' as mongo;
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';

import 'a_model.dart';

class SetupModel extends AModel {
  static final Logger _log = new Logger('UserModel');

  @override
  Logger get loggerImpl => _log;

  final UserModel userModel;

  SetupModel(this.userModel, AUserDataSource userDataSource): super(userDataSource);

  Future<SetupResponse> apply(SetupRequest request) async {
    await _checkIfSetupEnabled();

    await DataValidationException
        .performValidation((Map<String, String> fieldErrors) async {
//      if(StringTools.isNotNullOrWhitespace(request.databaseConnectionString)) {
//        try {
//          await mongo.MongoDatabase.testConnectionString(
//              request.databaseConnectionString);
//
//          settings.mongoConnectionString = request.databaseConnectionString;
//          await mongo.MongoDatabase.closeAllConnections();
//        } catch (e,st) {
//          _log.severe("apply", e, st);
//          fieldErrors["databaseConnectionString"] = e.toString();
//        }
//
//      } else if(await checkDatabase()) {
//        fieldErrors["databaseConnectionString"] = "Required";
//      }

      if (StringTools.isNotNullOrWhitespace(request.adminUser)) {
        try {
          await userModel.createUserWith(request.adminUser,
              request.adminPassword, UserPrivilege.admin,
              bypassAuthentication: true);
        } on DataValidationException catch (e) {
          fieldErrors.addAll(e.fieldErrors);
        }
      } else if (await checkForAdminUsers()) {
        fieldErrors["adminUser"] = "Required";
      }
    });

    await new File(setupLockFilePath).create();

    return await checkSetup();
  }

  Future<bool> checkDatabase() async {
    return false;
  }

  Future<bool> checkForAdminUsers() async {
    await _checkIfSetupEnabled();
    final List<User> admins = await userDataSource.getAdmins();
    return admins.isNotEmpty;
  }

  Future<SetupResponse> checkSetup() async {
    if (!await isSetupAvailable()) {
      throw new SetupDisabledException();
    }

    final SetupResponse output = new SetupResponse();

    output.adminUser = await checkForAdminUsers();

    return output;
  }



  Future<Null> _checkIfSetupEnabled() async {
    if (!await isSetupAvailable()) {
      throw new SetupDisabledException();
    }
  }
}
