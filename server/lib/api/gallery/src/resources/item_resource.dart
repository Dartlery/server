import 'dart:async';

import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery/tools.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';

import '../../gallery_api.dart';
import '../requests/create_item_request.dart';
import '../requests/item_search_request.dart';
import '../requests/update_item_request.dart';
import 'dart:convert';

class ItemResource extends AIdResource<Item> {
  static final Logger _log = new Logger('ItemResource');
  static const String _apiPath = GalleryApi.itemsPath;

  final ItemModel itemModel;

  ItemResource(this.itemModel);
  @override
  Logger get childLogger => _log;

  @override
  AIdBasedModel<Item> get idModel => itemModel;

  @override
  Future<IdResponse> create(Item item) => catchExceptionsAwait(
      () async => throw new NotImplementedException("Use createItem instead"));

  // Created only to satisfy the interface; should not be used, as creating a copy with each item should be required
  @ApiMethod(method: HttpMethod.post, path: '$_apiPath/')
  Future<IdResponse> createItem(CreateItemRequest newItem) =>
      catchExceptionsAwait(() async {
        if (newItem.file != null) {
          final List<List<int>> files =
              convertMediaMessagesToIntLists(<MediaMessage>[newItem.file]);
          if (files.length > 0) {
            newItem.item.fileData = files[0];
          }
        }
        final String output = await itemModel.create(newItem.item);
        return new IdResponse.fromId(output, generateRedirect(output));
      });

  @override
  @ApiMethod(method: HttpMethod.delete, path: '$_apiPath/{id}/')
  Future<VoidMessage> delete(String id) => deleteWithCatch(id);

  @override
  @ApiMethod(path: '$_apiPath/{id}/')
  Future<Item> getById(String id) =>
      catchExceptionsAwait(() => itemModel.getById(id));

  @ApiMethod(path: '$_apiPath/{id}/$tagApiPath/')
  Future<List<Tag>> getTagsByItemId(String id) =>
      catchExceptionsAwait(() async {
        final Item item = await itemModel.getById(id);
        return item.tags;
      });

  @ApiMethod(path: '$_apiPath/')
  Future<PaginatedResponse<String>> getVisibleIds(
          {int page: 0, int perPage: defaultPerPage, String cutoffDate}) =>
      catchExceptionsAwait(() async {
        DateTime dt;
        if (StringTools.isNotNullOrWhitespace(cutoffDate))
          dt = DateTime.parse(cutoffDate);

        return new PaginatedResponse<String>.convertPaginatedData(
            await itemModel.getVisible(
                page: page, perPage: perPage, cutoffDate: dt),
            (Item item) => item.id);
      });

  @ApiMethod(
      method: HttpMethod.put,
      path: '$_apiPath/{targetItemId}/merge/',
      description:
          "Merges the data from [sourceItemId] into the item specified by [id], and then deletes the item associated with [sourceItemId]")
  Future<Item> mergeItems(String targetItemId, IdRequest sourceItemId) =>
      catchExceptionsAwait(
          () => itemModel.merge(targetItemId, sourceItemId.id));

  @ApiMethod(method: HttpMethod.put, path: '$searchApiPath/$_apiPath')
  Future<PaginatedResponse<String>> searchVisible(ItemSearchRequest request) =>
      catchExceptionsAwait(() async =>
          new PaginatedResponse<String>.convertPaginatedData(
              await itemModel.searchVisible(request.tags,
                  page: request.page,
                  perPage: request.perPage,
                  cutoffDate: request.cutoffDate),
              (Item item) => item.id));

  @override
  @ApiMethod(method: HttpMethod.put, path: '$_apiPath/{id}/')
  Future<IdResponse> update(String id, Item item) =>
      updateWithCatch(id, item);

  @ApiMethod(method: HttpMethod.put, path: '$_apiPath/{id}/$tagApiPath/')
  Future<Null> updateTagsForItemId(String id, List<Tag> newTags) =>
      catchExceptionsAwait(() => itemModel.updateTags(id, newTags));
}
