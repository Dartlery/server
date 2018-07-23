import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'a_model.dart';
import 'package:orm/orm.dart';

class SettingsModel extends AModel {
  static final Logger _log = new Logger('SettingsModel');

  @override
  Logger get loggerImpl => _log;

  SettingsModel(DatabaseContext db)
      : super(db);

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
