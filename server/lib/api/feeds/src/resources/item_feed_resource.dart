import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:dartlery/api/src/a_resource.dart';
import 'package:logging/logging.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/data/feed/feed.dart';
import 'package:rpc/rpc.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery_shared/tools.dart';
import '../../feed_api.dart';
import '../../../api_tools.dart';

class ItemFeedResource extends AResource {
  static final Logger _log = new Logger('ItemResource');
  static const String _apiPath = "import";

  @override
  Logger get childLogger => _log;

  final ItemModel _itemModel;

  ItemFeedResource(this._itemModel);

  @ApiMethod(path: 'items/')
  Future<Feed> getVisibleItems(
          {int page: 0, int perPage: defaultPerPage, String tags}) =>
      catchExceptionsAwait<Feed>(() async {
        String title = "Recent items";
        PaginatedData<Item> items;
        if (isNotNullOrWhitespace(tags)) {
          final TagList tagList = new TagList.fromJson(tags);
          items = await _itemModel.searchVisible(tagList.toList(),
              page: page, perPage: perPage);
          title = "Recent items $tagList";
        } else {
          items = await _itemModel.getVisible(page: page, perPage: perPage);
        }
        return createItemFeed(items.data, title);
      });

  @ApiMethod(path: 'items/random/')
  Future<Feed> getRandomItems({int perPage: defaultPerRandomPage, String tags, bool imagesOnly: false}) =>
      catchExceptionsAwait<Feed>(() async {
        String title = "Random items";
        TagList tagList;

        if (isNotNullOrWhitespace(tags)) {
          tagList = new TagList.fromJson(tags);
          title = "$title $tagList";
        }
        final List<Item> items = await _itemModel.getRandom(
            filterTags: tagList?.toList(), perPage: perPage, imagesOnly: imagesOnly);
        return createItemFeed(items, title);
      });

//  @ApiMethod(method: HttpMethod.put, path: 'items/filter/{tags}/')
//  Future<PaginatedResponse<String>> searchVisible(ItemSearchRequest request) =>
//      catchExceptionsAwait(() async =>
//      new PaginatedResponse<String>.convertPaginatedData(
//          await itemModel.searchVisible(request.tags,
//              page: request.page,
//              perPage: request.perPage,
//              cutoffDate: request.cutoffDate),
//              (Item item) => item.id));

  Feed createItemFeed(List<Item> items, String title) {
    final Feed output = new Feed(title);

    output.homePageUrl = requestRoot;
    output.favicon = urlPath.join(requestRoot, "favicon.ico");
    output.feedUrl = context.requestUri.toString();

    for (Item i in items) {
      final FeedItem fItem = new FeedItem(i.id);
      String imageUrl;
      if (i.fullFileAvailable) {
        imageUrl = urlPath.join(requestRoot, filesPath, fullFileFolderName,
            i.id.substring(0, fileHashPrefixLength), i.id);
      } else {
        imageUrl = urlPath.join(requestRoot, filesPath, originalFileFolderName,
            i.id.substring(0, fileHashPrefixLength), i.id);
      }

      fItem.bannerImage = urlPath.join(
          requestRoot,
          filesPath,
          thumbnailFileFolderName,
          i.id.substring(0, fileHashPrefixLength),
          i.id);
      fItem.image = imageUrl;
      fItem.url = imageUrl;
      fItem.datePublished = i.uploaded;
      if (i.tags.length > 0) {
        fItem.tags = <String>[];
      }
      for (Tag t in i.tags) {
        fItem.tags.add(t.toString());
      }
      output.items.add(fItem);
    }

    return output;
  }
}
