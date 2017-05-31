import 'dart:async';

import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery_shared/global.dart';
import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';

import '../requests/replace_tags_requst.dart';

class TagResource extends AResource {
  static final Logger _log = new Logger('TagResource');

  final TagModel _tagModel;

  TagResource(this._tagModel);

  @override
  Logger get childLogger => _log;
  @override
  String get resourcePath => tagApiPath;

  @ApiMethod(
      method: HttpMethod.delete, path: 'tag_redirects/{tagId}/{tagCategory}')
  Future<Null> deleteRedirect(String id, String category) async {
    return catchExceptionsAwait(() async {
      throw new NotImplementedException();
      //await _tagModel.deleteRedirect(id, category);
    });
  }

  @ApiMethod(method: HttpMethod.put, path: '$tagApiPath/')
  Future<Null> replace(ReplaceTagsRequest request) async {
    return catchExceptionsAwait(() async {
      await _tagModel.replace(request.originalTags, request.newTags);
    });
  }

  @ApiMethod(method: HttpMethod.get, path: '$searchApiPath/$tagApiPath/{query}')
  Future<List<Tag>> search(String query) async {
    return catchExceptionsAwait(() async {
      return await _tagModel.search(query);
    });
  }

  @ApiMethod(method: HttpMethod.put, path: 'tag_redirects/')
  Future<Null> setRedirect(RedirectingTag request) async {
    return catchExceptionsAwait(() async {
      await _tagModel.setRedirect(request);
    });
  }

  @ApiMethod(method: HttpMethod.delete, path: 'tag_redirects/{id}/{category}/')
  Future<Null> clearRedirect(String id, String category) async {
    return catchExceptionsAwait(() async {
      await _tagModel.clearRedirect(id, category);
    });
  }

  @ApiMethod(method: HttpMethod.delete, path: 'tag_redirects/{id}/')
  Future<Null> clearRedirectWithoutCategory(String id) async {
    return catchExceptionsAwait(() async {
      await _tagModel.clearRedirect(id);
    });
  }


  @ApiMethod(method: HttpMethod.put, path: '$tagApiPath/{tagId}/{tagCategory}/')
  Future<Null> update(String tagId, String tagCategory, Tag newTag) async {
    return catchExceptionsAwait(() async {
      final Tag t = new Tag.withValues(tagId, category: tagCategory);
      await _tagModel.update(t, newTag);
    });
  }

  @ApiMethod(method: HttpMethod.put, path: '$tagApiPath/{tagId}/')
  Future<Null> updateWithoutCategory(String tagId, Tag newTag) async {
    return catchExceptionsAwait(() async {
      final Tag t = new Tag.withValues(tagId, category: null);
      await _tagModel.update(t, newTag);
    });
  }
}
