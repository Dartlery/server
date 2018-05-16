import 'dart:async';

import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery_shared/global.dart';
import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';

import '../requests/replace_tags_requst.dart';
import '../responses/paginated_tag_response.dart';

class TagResource extends AResource {
  static final Logger _log = new Logger('TagResource');

  final TagModel _tagModel;

  TagResource(this._tagModel);

  @override
  Logger get childLogger => _log;
  @override
  String get resourcePath => tagApiPath;

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

  @ApiMethod(method: HttpMethod.delete, path: 'tag/{id}/{category}/')
  Future<CountResponse> delete(String id, String category) async {
    return catchExceptionsAwait(() async {
      return new CountResponse(await _tagModel.delete(id, category));
    });
  }

  @ApiMethod(method: HttpMethod.delete, path: 'tag/{id}/')
  Future<CountResponse> deleteWithoutCategory(String id) async {
    return catchExceptionsAwait(() async {
      return new CountResponse(await _tagModel.delete(id, null));
    });
  }

  @ApiMethod(method: HttpMethod.get, path: '$tagApiPath/')
  Future<PaginatedTagResponse> getAllTagInfo(
      {int page: 0, int perPage: defaultPerPage, bool countAsc: null}) async {
    return catchExceptionsAwait<PaginatedTagResponse>(() async {
      return new PaginatedTagResponse.fromPaginatedData(await _tagModel
          .getAllInfo(page: page, perPage: perPage, countAsc: countAsc));
    });
  }

  @ApiMethod(method: HttpMethod.get, path: 'tag_redirects/')
  Future<List<TagInfo>> getRedirects() async {
    return catchExceptionsAwait<List<TagInfo>>(() async {
      return await _tagModel.getRedirects();
    });
  }

  @ApiMethod(method: HttpMethod.get, path: '$tagApiPath/{id}/{category}/')
  Future<TagInfo> getTagInfo(String id, String category) async {
    return catchExceptionsAwait<TagInfo>(() async {
      return _tagModel.getInfo(id, category);
    });
  }

  @ApiMethod(method: HttpMethod.get, path: '$tagApiPath/{id}/')
  Future<TagInfo> getTagInfoWithoutCategory(String id) async {
    return catchExceptionsAwait<TagInfo>(() async {
      return _tagModel.getInfo(id);
    });
  }

  @ApiMethod(method: HttpMethod.put, path: '$tagApiPath/')
  Future<CountResponse> replace(ReplaceTagsRequest request) async {
    return catchExceptionsAwait<CountResponse>(() async {
      return new CountResponse(
          await _tagModel.replace(request.originalTags, request.newTags));
    });
  }

  @ApiMethod(method: HttpMethod.delete, path: 'tag_info/')
  Future<Null> resetTagInfo() async {
    return catchExceptionsAwait(() async {
      await _tagModel.resetTagInfo();
    });
  }

  @ApiMethod(method: HttpMethod.get, path: '$searchApiPath/$tagApiPath/{query}')
  Future<PaginatedTagResponse> search(String query,
      {int page: 0,
      int perPage: defaultPerPage,
      bool countAsc: null,
      bool redirects: null}) async {
    return catchExceptionsAwait<PaginatedTagResponse>(() async {
      return new PaginatedTagResponse.fromPaginatedData(await _tagModel.search(
          query,
          countAsc: countAsc,
          perPage: perPage,
          page: page,
          redirects: redirects));
    });
  }

  @ApiMethod(method: HttpMethod.put, path: 'tag_redirects/')
  Future<Null> setRedirect(TagInfo request) async {
    return catchExceptionsAwait(() async {
      await _tagModel.setRedirect(request);
    });
  }

//  @ApiMethod(method: HttpMethod.put, path: '$tagApiPath/{tagId}/{tagCategory}/')
//  Future<Null> update(String tagId, String tagCategory, Tag newTag) async {
//    return catchExceptionsAwait(() async {
//      final Tag t = new Tag.withValues(tagId, category: tagCategory);
//      await _tagModel.update(t, newTag);
//    });
//  }
//
//  @ApiMethod(method: HttpMethod.put, path: '$tagApiPath/{tagId}/')
//  Future<Null> updateWithoutCategory(String tagId, Tag newTag) async {
//    return catchExceptionsAwait(() async {
//      final Tag t = new Tag.withValues(tagId, category: null);
//      await _tagModel.update(t, newTag);
//    });
//  }
}
