import 'package:dice/dice.dart';
import 'package:rpc/rpc.dart';
import 'package:dartlery/server.dart';
import 'src/resources/item_feed_resource.dart';
import 'package:path/path.dart' as path;
import 'package:dartlery_shared/tools.dart';
import '../api_tools.dart';
import 'package:dartlery_shared/global.dart';
export 'src/resources/item_feed_resource.dart';

import 'package:dice/dice.dart';
@Injectable()
@ApiClass(version: feedApiVersion, name: feedApiName, description: 'Feeds API')
class FeedApi {
  @ApiResource()
  final ItemFeedResource items;

  @inject
  FeedApi(this.items);

  static String get rootPath =>
      urlPath.join(requestRoot, apiPrefix, feedApiVersion, feedApiName);
}


class FeedModule extends Module{
  @override
  void configure() {
    register(ItemFeedResource).asSingleton();
    register(FeedApi).asSingleton();
  }
}