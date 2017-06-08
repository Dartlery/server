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
import 'package:option/option.dart';

import 'a_typed_model.dart';

class TagModel extends ATypedModel<TagInfo> {
  static final Logger _log = new Logger('TagModel');

  final ATagDataSource _tagDataSource;
  final AItemDataSource _itemDataSource;

  final ATagCategoryDataSource _tagCategoryDataSource;
  TagModel(this._tagDataSource, this._tagCategoryDataSource,
      this._itemDataSource, AUserDataSource userDataSource)
      : super(userDataSource);

  @override
  Logger get loggerImpl => _log;

  /// Validates the existence of any categories, and handles replacing any redirected tags
  Future<List<Tag>> handleTags(List<Tag> tags, {bool createMissingTags: true}) async {
    final TagList output = new TagList.from(tags);
    for (Tag tag in tags) {
      Option<TagInfo> dbTag = await _tagDataSource.getById(tag.id, tag.category);
      if (dbTag.isEmpty) {
        if(createMissingTags) {
          if (tag.hasCategory) {
            final Option<TagCategory> dbCategory = await _tagCategoryDataSource.getById(tag.category);
            if(dbCategory.isEmpty) {
              final TagCategory cat = new TagCategory.withValues(tag.category);
              await _tagCategoryDataSource.create(cat);
            } else {
              tag.category = dbCategory.first.id;
            }
          }
          await _tagDataSource.create(new TagInfo.copy(tag));
        }
      } else {
        final TagList pastRedirects = new TagList();
        Tag redirect;
        while (dbTag.first.redirect!=null) {
          final TagInfo rTag = dbTag.first;

          redirect = rTag.redirect;
          if (pastRedirects.contains(redirect))
            throw new Exception("Tag redirect loop detected: $pastRedirects");
          pastRedirects.add(redirect);
          dbTag = await _tagDataSource.getById(redirect.id, redirect.category);
          if(dbTag.isEmpty)
            throw new Exception("Redirect target not found: $redirect");
        }
        if (redirect != null) {
          if (!output.contains(redirect)) output.add(redirect);
          output.remove(tag);
        } else {
          tag.id = dbTag.first.id;
          tag.category = dbTag.first.category;
        }
      }
    }
    tags.clear();
    tags.addAll(output.toList());
    return tags;
  }

  Future<Null> validateTag(Tag t) {
    return validate(new TagInfo.copy(t));
  }

  Future<TagInfo> getInfo(String id, [String category]) async {
    final Option<TagInfo> output = await _tagDataSource.getById(id, category);
    if(output.isEmpty)
      throw new NotFoundException("Tag not found: ${Tag.formatTag(id, category)}");
    return output.first;
  }

  Future<List<TagInfo>> getAllInfo() async {
    final List<TagInfo> output = await _tagDataSource.getAll();;
    return output;
  }

  /// Replaces the $originalTags with the $newTags. This does not actually delete any tags.
  /// Images with the original tags will be updated to have the new tags.
  /// Returns the count of items that had their tags updated.
  Future<int> replace(List<Tag> originalTags, List<Tag> newTags) async {
    await validateUpdatePrivilegeRequirement();

    for (Tag t in originalTags) {
      await validateTag(t);
    }
    for (Tag t in newTags) {
      await validateTag(t);
    }
    newTags = await handleTags(newTags);

    final int output = await _itemDataSource.replaceTags(originalTags, newTags);

    await _tagDataSource.refreshTagCount(new TagDiff(originalTags, newTags).different);

    return output;
  }

  Future<int> delete(String id, String category) async {
    await validateDeletePrivileges();

    final TagInfo t = new TagInfo.withValues(id, category);
    validate(t);

    final int output = await _itemDataSource.replaceTags([t], []);

    if(await _tagDataSource.existsById(t.id, t.category))
      await _tagDataSource.deleteById(t.id, t.category);

    return output;
  }

  Future<List<TagInfo>> getRedirects()  async {
    await validateReadPrivilegeRequirement();
    return await _tagDataSource.getRedirects();
  }

  Future<List<TagInfo>> search(String query, {int limit: 10, bool countAsc}) async {
    await validateReadPrivilegeRequirement();

    final List<Tag> output = await _tagDataSource.search(query, limit: limit, countAsc: countAsc);
    return output;
  }

  Future<Null> clearRedirect(String id, [String category]) async {
    await validateUpdatePrivilegeRequirement();

    final Option<TagInfo> tagOpt = await _tagDataSource.getById(id, category);

    if(tagOpt.isEmpty)
      throw new NotFoundException("Specified tag not found: ${Tag.formatTag(id, category)}");

    final TagInfo tag = tagOpt.first;

    tag.redirect = null;

    await _tagDataSource.update(id, category, tag);
  }

  Future<int> setRedirect(TagInfo redirect) async {
    await validateUpdatePrivilegeRequirement();

    await validate(redirect);
    await validateTag(redirect.redirect);

    await DataValidationException.performValidation<int>((Map<String,String> fieldErrors) async {
      if(redirect==redirect.redirect) {
        fieldErrors["redirect"] = "Cannot be the same as start";
      }
    });

    Tag end = redirect.redirect;

    Option<TagInfo> dbEnd = await _tagDataSource.getById(end.id, end.category);
    if (dbEnd.isEmpty) {
      await _tagDataSource.create(new TagInfo.copy(end));
      dbEnd = await _tagDataSource.getById(end.id, end.category);
    }

    final TagList pastRedirects = new TagList();
    pastRedirects.add(redirect);
    TagInfo dbRedirect = dbEnd.first;
    while (dbRedirect.redirect != null) {
      end = dbRedirect.redirect;
      if (pastRedirects.contains(end))
        throw new InvalidInputException(
            "Specified redirect would cause a redirect loop: ");
      pastRedirects.add(end);
      dbEnd = await _tagDataSource.getById(end.id, end.category);
      if(dbEnd.isEmpty)
        throw new Exception("Tag in redirect chain not found: $end");
      if(!(dbEnd.first is TagInfo))
        break;
      dbRedirect = dbEnd.first;
    }

    redirect.count = 0;

    if(!await _tagDataSource.existsById(redirect.id, redirect.category)) {
      await _tagDataSource.create(redirect);
    } else {
      await _tagDataSource.update(redirect.id, redirect.category, redirect);
    }
    final int changed = await _itemDataSource.replaceTags([redirect], [end]);

    await _tagDataSource.refreshTagCount([redirect, end]);


    return changed;
  }

  Future<Null> resetTagInfo() async {
    await _tagDataSource.cleanUpTags();
  }

//  Future<Null> update(Tag originalTag, Tag newTag) async {
//    await validateUpdatePrivilegeRequirement();
//
//    await validate(originalTag);
//    await validate(newTag);
//
//    newTag = (await handleTags([newTag], createMissingTags: false)).first;
//
//    if (originalTag.equals(newTag))
//      throw new InvalidInputException("Please specify different tags");
//
//    await _tagDataSource.update(originalTag.id, originalTag.category, newTag);
//    await _itemDataSource.replaceTags(<Tag>[originalTag], <Tag>[newTag]);
//  }

  @override
  Future<Null> validateFields(TagInfo tag, Map<String, String> fieldErrors,
      {String existingId: null}) async {
    if (StringTools.isNullOrWhitespace(tag.id)) fieldErrors["id"] = "Required";

    if(tag.redirect!=null) {
      await validate(new TagInfo.copy(tag.redirect));
    }
  }
}
