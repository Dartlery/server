import 'dart:async';
import 'package:crypt/crypt.dart';
import 'package:logging/logging.dart';
import 'package:option/option.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:dartlery/data_sources/data_sources.dart' as data_sources;
import 'a_id_based_model.dart';
import 'a_model.dart';

class TagCategoryModel extends AIdBasedModel<TagCategory> {
  static final Logger _log = new Logger('TagCategoryModel');

  ATagCategoryDataSource _tagCategoryDataSource;

  TagCategoryModel(this._tagCategoryDataSource, AUserDataSource userDataSource)
      : super(userDataSource);

  @override
  Logger get loggerImpl => _log;

  @override
  ATagCategoryDataSource get dataSource => _tagCategoryDataSource;

  @override
  String get defaultReadPrivilegeRequirement => UserPrivilege.moderator;
//
//  @override
//  Future<String> update(String id, TagCategory t,
//      {bool bypassAuthentication: false}) async {
//    final String output = await super.update(id, t, bypassAuthentication: bypassAuthentication);
//
//    return output;
//  }

  @override
  Future<Null> validateFields(
      TagCategory tagCategory, Map<String, String> fieldErrors,
      {String existingId: null}) async {
    await super.validateFields(tagCategory, fieldErrors);

    if (isNullOrWhitespace(tagCategory.color)) {
      fieldErrors["color"] = "Required";
    }

    if (isNullOrWhitespace(tagCategory.color)) {
      fieldErrors["color"] = "Required";
    } else if (!hexColorRegex.hasMatch(tagCategory.color)) {
      fieldErrors["color"] = "Invalid";
    }
  }
}
