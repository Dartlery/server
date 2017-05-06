import 'tag_categories_page/tag_categories_page.dart';
import 'item_browse/item_browse.dart';
import 'setup/setup_page.dart';
import 'users_page/users_page.dart';
import 'item_view/item_view.dart';
import 'deduplicate/deduplicate.dart';

export 'tag_categories_page/tag_categories_page.dart';
export 'item_browse/item_browse.dart';
export 'setup/setup_page.dart';
export 'users_page/users_page.dart';
export 'item_view/item_view.dart';
export 'deduplicate/deduplicate.dart';

const List<Type> pageDirectives = const <Type>[
  TagCategoriesPage,
  ItemBrowseComponent,
  SetupPage,
  UsersPage,
  ItemViewPage,
  DeduplicatePage
];
