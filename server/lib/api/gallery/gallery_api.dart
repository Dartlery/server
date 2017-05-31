import 'package:dartlery_shared/global.dart';
import 'package:di/di.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:rpc/rpc.dart';

import 'src/resources/item_resource.dart';
import 'src/resources/setup_resource.dart';
import 'src/resources/user_resource.dart';
import 'src/resources/tag_resource.dart';
import 'src/resources/tag_categories_resource.dart';
import 'src/resources/extension_data_resource.dart';

export 'src/resources/item_resource.dart';
export 'src/resources/setup_resource.dart';
export 'src/resources/user_resource.dart';
import 'package:dartlery/model/model.dart';

//export 'src/requests/bulk_item_action_request.dart';
//export 'src/requests/item_action_request.dart';
//export 'src/requests/create_item_request.dart';
//export 'src/requests/update_item_request.dart';
//export 'src/requests/transfer_request.dart';
export 'src/requests/password_change_request.dart';
export 'src/requests/replace_tags_requst.dart';

@ApiClass(
    version: galleryApiVersion, name: galleryApiName, description: 'Item REST API')
class GalleryApi {
  static const String importPath = "import";
  static const String itemsPath = "items";
  static const String usersPath = "users";

  @ApiResource()
  final ItemResource items;

  @ApiResource()
  final UserResource users;

  @ApiResource()
  final SetupResource setup;

  @ApiResource()
  final TagResource tags;

  @ApiResource()
  final TagCategoriesResource tagCategories;

  @ApiResource()
  final ExtensionDataResource extensionData;

  GalleryApi(this.items, this.users, this.setup, this.tagCategories, this.tags, this.extensionData);

  static final Module injectorModules = new Module()
    ..bind(ItemResource)
    ..bind(UserResource)
    ..bind(SetupResource)
    ..bind(TagResource)
    ..bind(TagCategoriesResource)
    ..bind(ExtensionDataResource)
    ..bind(GalleryApi);
}
