import 'dart:async';
import 'dart:io';

import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/data_sources/mongo/mongo.dart' as mongo;
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';

import 'a_typed_model.dart';

class TagModel extends ATypedModel<Tag> {
  static final Logger _log = new Logger('UserModel');

  final ATagDataSource _tagDataSource;
  final AItemDataSource _itemDataSource;

  final ATagCategoryDataSource _tagCategoryDataSource;
  TagModel(this._tagDataSource, this._tagCategoryDataSource, this._itemDataSource,
      AUserDataSource userDataSource)
      : super(userDataSource);

  @override
  Logger get loggerImpl => _log;


  Future<Null> update(Tag originalTag, Tag newTag) async {
    await validateUpdatePrivilegeRequirement();

    await validate(originalTag);
    await validate(newTag);

    await _tagDataSource.update(originalTag.id, originalTag.category, newTag);
    await _itemDataSource.replaceTags(<Tag>[originalTag], <Tag>[newTag]);
  }

  Future<Null> replace(List<Tag> originalTags, List<Tag> newTags) async {
    await validateUpdatePrivilegeRequirement();

    for(Tag t in originalTags) {
      await validate(t);
    }
    for(Tag t in newTags) {
      await validate(t);
    }

    for(Tag t in newTags) {
      if(! await _tagDataSource.existsById(t.id, t.category))
        await _tagDataSource.create(t);
    }

    await _itemDataSource.replaceTags(originalTags, newTags);
  }

  Future<List<Tag>> search(String query, {int limit: 10}) async {
    await validateReadPrivilegeRequirement();

    final List<Tag> output = await _tagDataSource.search(query, limit: limit);
    return output;
  }

  @override
  Future<Null> validateFields(Tag tag, Map<String, String> fieldErrors,
      {String existingId: null}) async {

    if(StringTools.isNullOrWhitespace(tag.id))
      fieldErrors["id"] = "Required";

    if (StringTools.isNotNullOrWhitespace(tag.category)) {
      final bool result = await _tagCategoryDataSource.existsById(tag.category);
      if (!result) {
        fieldErrors["category"] = "Not found";
      }
    }
  }
}
