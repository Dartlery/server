import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/data/data.dart';
import 'package:orm/orm.dart';
import 'a_id_based_model.dart';

class TagCategoryModel extends AIdBasedModel<TagCategory, String> {
  static final Logger _log = new Logger('TagCategoryModel');


  TagCategoryModel(DatabaseContext db)
      : super(db);

  @override
  Logger get loggerImpl => _log;

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
