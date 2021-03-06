import 'tag_categories_page/tag_categories_page.dart';
import 'item_browse/item_browse.dart';
import 'setup/setup_page.dart';
import 'users_page/users_page.dart';
import 'item_view/item_view.dart';
import 'deduplicate/deduplicate.dart';
import 'tags/tags_page.dart';
import 'import/import_page.dart';
import 'trash/trash_page.dart';
import 'deduplicate_item/deduplicate_item.dart';

export 'tag_categories_page/tag_categories_page.dart';
export 'item_browse/item_browse.dart';
export 'setup/setup_page.dart';
export 'users_page/users_page.dart';
export 'item_view/item_view.dart';
export 'deduplicate/deduplicate.dart';
export 'tags/tags_page.dart';
export 'import/import_page.dart';
export 'trash/trash_page.dart';
export 'deduplicate_item/deduplicate_item.dart';

const List<Type> pageDirectives = const <Type>[
  TagCategoriesPage,
  ItemBrowseComponent,
  SetupPage,
  UsersPage,
  ItemViewPage,
  DeduplicatePage,
  DeduplicateItemPage,
  TagsPage,
  ImportPage,
  TrashPage
];
