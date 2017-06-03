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

class TagModel extends ATypedModel<Tag> {
  static final Logger _log = new Logger('UserModel');

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
      Option<Tag> dbTag = await _tagDataSource.getById(tag.id, tag.category);
      if (dbTag.isEmpty) {
        if(createMissingTags) {
          if (!StringTools.isNotNullOrWhitespace(tag.category)) {
            if (StringTools.isNotNullOrWhitespace(tag.category) &&
                !await _tagCategoryDataSource.existsById(tag.category)) {
              final TagCategory cat = new TagCategory.withValues(tag.category);
              await _tagCategoryDataSource.create(cat);
            }
          }
          await _tagDataSource.create(tag);
        }
      } else {
        final TagList pastRedirects = new TagList();
        Tag redirect;
        while (dbTag.first is RedirectingTag) {
          final RedirectingTag rTag = dbTag.first;
          if(rTag.redirect==null)
            continue;

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
        }
      }
    }
    tags.clear();
    tags.addAll(output.toList());
    return tags;
  }

  /// Replaces the $originalTags with the $newTags. This does not actually delete any tags.
  /// Images with the original tags will be updated to have the new tags.
  Future<Null> replace(List<Tag> originalTags, List<Tag> newTags) async {
    await validateUpdatePrivilegeRequirement();

    for (Tag t in originalTags) {
      await validate(t);
    }
    for (Tag t in newTags) {
      await validate(t);
    }
    newTags = await handleTags(newTags);

    await _itemDataSource.replaceTags(originalTags, newTags);
  }

  Future<List<RedirectingTag>> getRedirects()  async {
    await validateReadPrivilegeRequirement();

    return await _tagDataSource.getRedirects();
  }

  Future<List<Tag>> search(String query, {int limit: 10}) async {
    await validateReadPrivilegeRequirement();

    final List<Tag> output = await _tagDataSource.search(query, limit: limit);
    return output;
  }

  Future<Null> clearRedirect(String id, [String category]) async {
    await validateUpdatePrivilegeRequirement();

    final Option<Tag> tagOpt = await _tagDataSource.getById(id, category);
    if(tagOpt.isEmpty)
      throw new NotFoundException("Specified tag not found: ${Tag.formatTag(id, category)}");

    final Tag tag = tagOpt.first;

    if(tag is RedirectingTag) {
      tag.redirect = null;
    }

    await _tagDataSource.update(id, category, tag);
  }

  Future<Null> setRedirect(RedirectingTag redirect) async {
    await validateUpdatePrivilegeRequirement();

    await validate(redirect);
    await validate(redirect.redirect);

    await DataValidationException.performValidation((Map<String,String> fieldErrors) async {
      if(redirect==redirect.redirect) {
        fieldErrors["redirect"] = "Cannot be the same as start";
      }
    });

    Tag end = redirect.redirect;

    Option<Tag> dbEnd = await _tagDataSource.getById(end.id, end.category);
    if (dbEnd.isEmpty) {
      await _tagDataSource.create(end);
      dbEnd = await _tagDataSource.getById(end.id, end.category);
    } else if(dbEnd.first is RedirectingTag) {
      final TagList pastRedirects = new TagList();
      pastRedirects.add(redirect);
      RedirectingTag dbRedirect = dbEnd.first;
      while (dbRedirect.redirect != null) {
        end = dbRedirect.redirect;
        if (pastRedirects.contains(end))
          throw new InvalidInputException(
              "Specified redirect would cause a redirect loop: ");
        pastRedirects.add(end);
        dbEnd = await _tagDataSource.getById(end.id, end.category);
        if(dbEnd.isEmpty)
          throw new Exception("Tag in redirect chain not found: $end");
        if(!(dbEnd.first is RedirectingTag))
          break;
        dbRedirect = dbEnd.first;
      }
    }

    if(!await _tagDataSource.existsById(redirect.id, redirect.category)) {
      await _tagDataSource.create(redirect);
    } else {
      await _tagDataSource.update(redirect.id, redirect.category, redirect);
    }
    await _itemDataSource.replaceTags([redirect], [end]);
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
  Future<Null> validateFields(Tag tag, Map<String, String> fieldErrors,
      {String existingId: null}) async {
    if (StringTools.isNullOrWhitespace(tag.id)) fieldErrors["id"] = "Required";

    if (StringTools.isNotNullOrWhitespace(tag.category)) {
      final bool result = await _tagCategoryDataSource.existsById(tag.category);
      if (!result) {
        fieldErrors["category"] = "Not found";
      }
    }
  }
}
