import 'dart:async';
import 'dart:io';

import 'package:dartlery_shared/global.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/data_sources/mongo/mongo.dart' as mongo;
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:tools/tools.dart';
import 'package:logging/logging.dart';
import 'package:server/model/model.dart';
import 'package:server/server.dart';

class SetupModel extends AModel {
  static final Logger _log = new Logger('UserModel');

  @override
  Logger get loggerImpl => _log;

  final UserModel userModel;

  SetupModel(this.userModel, AUserDataSource userDataSource,
      APrivilegeSet privilegeSet)
      : super(userDataSource, privilegeSet);

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

      if (isNotNullOrWhitespace(request.adminUser)) {
        try {
          await userModel.createUserWith(
              request.adminUser, request.adminPassword, APrivilegeSet.admin,
              bypassAuthentication: true);
        } on DataValidationException catch (e) {
          fieldErrors.addAll(e.fieldErrors);
        }
      } else if (await checkForAdminUsers()) {
        fieldErrors["adminUser"] = "Required";
      }
    });

    await new File(dartleryServerContext.setupLockFilePath)
        .create();

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
    if (!await dartleryServerContext.isSetupAvailable()) {
      throw new SetupDisabledException();
    }

    final SetupResponse output = new SetupResponse();

    output.adminUser = await checkForAdminUsers();

    return output;
  }

  Future<Null> _checkIfSetupEnabled() async {
    if (!await dartleryServerContext.isSetupAvailable()) {
      throw new SetupDisabledException();
    }
  }
}
