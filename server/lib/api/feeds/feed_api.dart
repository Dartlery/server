import 'package:di/di.dart';
import 'package:rpc/rpc.dart';
import 'package:dartlery/server.dart';
import 'src/resources/item_feed_resource.dart';
import 'package:path/path.dart' as path;
import 'package:dartlery_shared/tools.dart';
import '../api_tools.dart';
export 'src/resources/item_feed_resource.dart';

@ApiClass(
    version: FeedApi.apiVersion,
    name: FeedApi.apiName,
    description: 'Feeds API')
class FeedApi {
  static const String apiName = "feeds";
  static const String apiVersion = "1";

  @ApiResource()
  final ItemFeedResource items;

  FeedApi(this.items);

  static final Module injectorModules = new Module()
    ..bind(ItemFeedResource)
    ..bind(FeedApi);

  static String get rootPath =>
      urlPath.join(requestRoot, apiPrefix, apiVersion, apiName);
}
