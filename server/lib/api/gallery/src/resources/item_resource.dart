import 'dart:async';

import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/tools.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';

import '../../gallery_api.dart';
import '../requests/create_item_request.dart';
import '../requests/item_search_request.dart';
import '../responses/paginated_item_response.dart';

class ItemResource extends AIdResource<Item> {
  static final Logger _log = new Logger('ItemResource');
  static const String _apiPath = GalleryApi.itemsPath;

  final ItemModel itemModel;

  ItemResource(this.itemModel);
  @override
  Logger get childLogger => _log;

  @override
  AIdBasedModel<Item> get idModel => itemModel;

  // Created only to satisfy the interface; should not be used.
  @override
  Future<IdResponse> create(Item item) => catchExceptionsAwait(
      () async => throw new NotImplementedException("Use createItem instead"));

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
  Future<PaginatedItemResponse> getVisibleIds(
          {int page: 0, int perPage: defaultPerPage, String cutoffDate, bool inTrash: false}) =>
      catchExceptionsAwait(() async {
        DateTime dt;
        if (isNotNullOrWhitespace(cutoffDate))
          dt = DateTime.parse(cutoffDate);

        return new PaginatedItemResponse.convertPaginatedData(
            await itemModel.getVisible(
                page: page, perPage: perPage, cutoffDate: dt, inTrash: inTrash),
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

  @ApiMethod(method: HttpMethod.get, path: '$searchApiPath/$_apiPath/{tags}/')
  Future<PaginatedItemResponse> searchVisible(String tags, {int page: 0, int perPage: defaultPerPage, String cutoffDate, bool inTrash: false}) =>
      catchExceptionsAwait(() async  {
          final List<Tag> queryTags  = new TagList.fromJson(tags).toList();
          DateTime cutoffDateParsed;
          if(isNotNullOrWhitespace(cutoffDate)) {
            cutoffDateParsed = DateTime.parse(cutoffDate);
          }

          return new PaginatedItemResponse.convertPaginatedData(
              await itemModel.searchVisible(queryTags,
                  page: page,
                  perPage: perPage,
                  cutoffDate: cutoffDateParsed,
              inTrash: inTrash),
              (Item item) => item.id)..queryTags=queryTags;
      });

  @override
  @ApiMethod(method: HttpMethod.put, path: '$_apiPath/{id}/')
  Future<IdResponse> update(String id, Item item) => updateWithCatch(id, item);

  @ApiMethod(method: HttpMethod.put, path: '$_apiPath/{id}/$tagApiPath/')
  Future<Null> updateTagsForItemId(String id, List<Tag> newTags) =>
      catchExceptionsAwait(() => itemModel.updateTags(id, newTags));
}
