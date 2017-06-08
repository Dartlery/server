import 'dart:async';

import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';

import '../../gallery_api.dart';
import '../requests/password_change_request.dart';
import 'package:dartlery_shared/global.dart';

class TagCategoriesResource extends AIdResource<TagCategory> {
  static final Logger _log = new Logger('UserResource');

  final TagCategoryModel _tagCategoryModel;
  TagCategoriesResource(this._tagCategoryModel);

  @override
  Logger get childLogger => _log;

  @override
  AIdBasedModel<TagCategory> get idModel => _tagCategoryModel;

  @override
  @ApiMethod(method: 'POST', path: '${tagCategoriesApiPath}/')
  Future<IdResponse> create(TagCategory tagCategory) => createWithCatch(tagCategory);

  @ApiMethod(method: 'GET', path: '${tagCategoriesApiPath}/')
  Future<List<String>> getAllIds() => catchExceptionsAwait(() async {
    final List<TagCategory> data = await _tagCategoryModel.getAll();
    final List<String> output = <String>[];
    for(TagCategory tc in data) {
      output.add(tc.id);
    }
    return output;
  });


  @override
  @ApiMethod(method: 'DELETE', path: '${tagCategoriesApiPath}/{id}/')
  Future<VoidMessage> delete(String id) => deleteWithCatch(id);

  @override
  String generateRedirect(String newId) =>
      "$serverApiRoot${tagCategoriesApiPath}/$newId";

  @override
  @ApiMethod(path: '${tagCategoriesApiPath}/{id}/')
  Future<TagCategory> getById(String id) => getByUuidWithCatch(id);

  @override
  @ApiMethod(method: 'PUT', path: '${tagCategoriesApiPath}/{id}/')
  Future<IdResponse> update(String id, TagCategory tagCategory) async {
    throw new NotImplementedException();
   // updateWithCatch(id, tagCategory);
  }
}
