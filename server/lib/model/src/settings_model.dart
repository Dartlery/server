import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:server/model/model.dart';
import 'package:tools/tools.dart';

class SettingsModel extends AModel {
  static final Logger _log = new Logger('SettingsModel');

  @override
  Logger get loggerImpl => _log;

  final ASettingsDataSource _settingsDataSource;

  SettingsModel(this._settingsDataSource, AUserDataSource userDataSource,
      APrivilegeSet privilegeSet)
      : super(userDataSource, privilegeSet);

//  Future<Map<String,String>> get() async {
//    await validateGetPrivileges();
//    return _settingsDataSource.getAll();
//  }
//
//  Future<Null> set(Map<String,String> data) async {
//    await validateUpdatePrivilegeRequirement();
//    return _settingsDataSource.setAll(data);
//  }
}
