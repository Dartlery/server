import 'dart:async';

import 'package:dartlery_shared/global.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';
import '../../gallery_api.dart';
import '../requests/create_item_request.dart';
import '../requests/update_item_request.dart';
import 'package:dartlery/tools.dart';

class ItemResource extends AIdResource<Item> {
  static final Logger _log = new Logger('ItemResource');
  @override
  Logger get childLogger => _log;

  static const String _apiPath = GalleryApi.itemsPath;

  final ItemModel itemModel;
  ItemResource(this.itemModel);

  @override
  AIdBasedModel<Item> get idModel => itemModel;

  @ApiMethod(method: 'POST', path: '$_apiPath/')
  Future<IdResponse> createItem(CreateItemRequest newItem) => catchExceptionsAwait(() async {
    if (newItem.file != null) {
      final List<List<int>> files = convertMediaMessagesToIntLists(<MediaMessage>[newItem.file]);
      if(files.length>0) {
        newItem.item.fileData = files[0];
      }
    }
    final String output = await itemModel
        .create(newItem.item);
    return new IdResponse.fromId(output, generateRedirect(output));

  });

  // Created only to satisfy the interface; should not be used, as creating a copy with each item should be required
  @override
  Future<IdResponse> create(Item item) =>catchExceptionsAwait(() async =>
      throw new NotImplementedException("Use createItem instead"));

  @override
  @ApiMethod(method: 'DELETE', path: '$_apiPath/{id}/')
  Future<VoidMessage> delete(String id) => deleteWithCatch(id);

  @ApiMethod(path: '$_apiPath/')
  Future<PaginatedResponse<String>> getVisibleIds(
      {int page: 0, int perPage: defaultPerPage}) =>
      catchExceptionsAwait(() async =>
          new PaginatedResponse<String>.convertPaginatedData(
              await itemModel.getVisible(page: page, perPage: perPage),
              (Item item) => item.id));

  @override
  @ApiMethod(path: '$_apiPath/{id}/')
  Future<Item> getById(String id)  =>
      catchExceptionsAwait(() => itemModel.getById(id));

  @ApiMethod(path: 'search/{query}/')
  Future<PaginatedResponse<String>> searchVisible(String query,
          {int page: 0, int perPage: defaultPerPage}) =>
      catchExceptionsAwait(() async =>
          new PaginatedResponse<String>.convertPaginatedData(
              await itemModel
                  .searchVisible(query, page: page, perPage: perPage),
              (Item item) => item.id));

  @override
  Future<IdResponse> update(String id, Item item) =>
      throw new NotImplementedException("User updateItem");

  @ApiMethod(method: 'PUT', path: '$_apiPath/{id}/')
  Future<IdResponse> updateItem(String id, UpdateItemRequest request) =>
      updateWithCatch(id, request.item, mediaMessages: request.files);
}
