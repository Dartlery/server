import 'package:rpc/rpc.dart';

export 'src/exceptions/redirecting_exception.dart';
export 'src/a_id_resource.dart';
export 'src/a_resource.dart';
export 'src/responses/id_response.dart';
export 'src/responses/paginated_response.dart';
export 'src/requests/id_request.dart';
export 'gallery/src/requests/item_search_request.dart';
export 'gallery/src/requests/setup_request.dart';
export 'gallery/src/responses/setup_response.dart';
export 'gallery/src/requests/create_item_request.dart';
export 'gallery/src/requests/update_item_request.dart';
export 'gallery/src/responses/paginated_item_response.dart';
export 'src/responses/count_response.dart';
export 'feeds/feed_api.dart';

const String setupApiPath = "setup";
const String searchApiPath = "search";
const String tagApiPath = "tags";
const String tagCategoriesApiPath = "tag_categories";
const String extensionDataApiPath = "extension_data";
