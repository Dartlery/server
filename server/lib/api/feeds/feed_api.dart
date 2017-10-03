import 'package:di/di.dart';
import 'package:rpc/rpc.dart';
import 'src/resources/item_feed_resource.dart';
import 'package:tools/tools.dart';
import 'package:dartlery_shared/global.dart';
export 'src/resources/item_feed_resource.dart';
import 'package:server/api/api.dart';
import 'package:server/api/api_tools.dart';

@ApiClass(version: feedApiVersion, name: feedApiName, description: 'Feeds API')
class FeedApi extends AApi {
  @ApiResource()
  final ItemFeedResource items;

  FeedApi(this.items);

  static final Module injectorModules = new Module()
    ..bind(ItemFeedResource)
    ..bind(FeedApi);

  static String get rootPath =>
      urlPath.join(requestRoot, apiPrefix, feedApiVersion, feedApiName);
}
