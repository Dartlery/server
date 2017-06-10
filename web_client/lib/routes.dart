import 'package:angular2/router.dart';
import 'package:dartlery/views/pages/pages.dart';

const Route tagCategoriesRoute = const Route(
  path: '/tagCategories',
  name: 'TagCategories',
  component: TagCategoriesPage,
);
const Route tagsRoute = const Route(
  path: '/tags',
  name: 'Tags',
  component: TagsPage,
);
const Route homeRoute = const Route(
    path: '/',
    name: "Home",
    component: ItemBrowseComponent,
    useAsDefault: true);

const String idRouteParameter = "id";

const Route itemsPageRoute = const Route(
    path: '/items/:$pageRouteParameter',
    name: 'ItemsPage',
    component: ItemBrowseComponent);

const Route itemsSearchPageRoute = const Route(
    path: '/items/search/:$queryRouteParameter/:$pageRouteParameter',
    name: 'ItemsSearchPage',
    component: ItemBrowseComponent);

const Route itemsSearchRoute = const Route(
    path: '/items/search/:$queryRouteParameter',
    name: 'ItemsSearch',
    component: ItemBrowseComponent);

const Route itemViewRoute = const Route(
  path: '/item/:$idRouteParameter',
  name: 'Item',
  component: ItemViewPage,
);

const String pageRouteParameter = "page";

const String queryRouteParameter = "query";

const List<Route> routes = const <Route>[
  homeRoute,
  itemsPageRoute,
  itemsSearchRoute,
  itemsSearchPageRoute,
  itemViewRoute,
  tagCategoriesRoute,
  setupRoute,
  usersRoute,
  deduplicateRoute,
  tagsRoute
];

const Route setupRoute = const Route(
  path: '/setup',
  name: 'Setup',
  component: SetupPage,
);

const Route usersRoute = const Route(
  path: '/users',
  name: 'Users',
  component: UsersPage,
);

const Route deduplicateRoute = const Route(
  path: '/deduplicate/',
  name: 'Deduplicate',
  component: DeduplicatePage,
);

const Route deduplicateItemRoute = const Route(
  path: '/deduplicate/:$idRouteParameter',
  name: 'DeduplicateItem',
  component: DeduplicatePage,
);
