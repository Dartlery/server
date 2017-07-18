import 'dart:collection';
import 'dart:async';
import 'dart:html';

import 'package:angular2/angular2.dart';
import 'package:angular2/platform/common.dart';
import 'package:angular2/router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/client.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/routes.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery/views/controls/auth_status_component.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import '../../controls/tag_entry_component.dart';
import '../src/a_page.dart';
import 'package:dartlery/views/controls/item_grid/item_grid.dart';

@Component(
    selector: 'item-browse',
    providers: const [materialProviders],
    directives: const [
      materialDirectives,
      ROUTER_DIRECTIVES,
      AuthStatusComponent,
      TagEntryComponent,
      ItemGrid
    ],
    styleUrls: const ["../../shared.css"],
    template: '''
    <auth-status (authedChanged)="onAuthChanged(\$event)"></auth-status>

    <div *ngIf="noItemsFound&&!processing" class="no-items">No Items Found</div>
    <item-grid [items]="items" (selectedItemsChanged)="itemSelectChanged()"></item-grid>

    <div class="sidebar">
    ''')
class TrashPage extends APage implements OnInit, OnDestroy {
  static final Logger _log = new Logger("TrashPage");
  bool curatorAuth = false;

  bool userLoggedIn;
  final ApiService _api;
  final RouteParams _routeParams;

  final Router _router;
  final RouteData _routeData;
  final AuthenticationService _auth;
  final List<IdWrapper> items = <IdWrapper>[];
  String _currentQuery = "";

  StreamSubscription<String> _searchSubscription;

  StreamSubscription<PageAction> _pageActionSubscription;
  StreamSubscription<bool> _authChangedSubscription;

  List<Tag> palletTags = <Tag>[];

  final ItemSearchService _search;

  TrashPage(this._api, this._routeParams,
      PageControlService pageControl, this._router, this._auth, this._search, this._routeData)
      : super(_auth, _router, pageControl) {
    setActions();
    pageControl.setPageTitle("Trash");
  }

  @override
  Logger get loggerImpl => _log;

  bool get noItemsFound => items.isEmpty;

  List<IdWrapper> get selectedItems =>
      items.where((IdWrapper item) => item.selected).toList();

  Future<Null> deleteSelected() async {
    if (selectedItems.isEmpty) return;
    await performApiCall(() async {
    while(selectedItems.isNotEmpty) {
      final IdWrapper item = selectedItems[0];
        await _api.items.delete(item.id, permanent: true);
        items.removeAt(0);
    }
    });
    await refresh();
  }

  Future<Null> restoreSelected() async {
    if (selectedItems.isEmpty) return;
    await performApiCall(() async {
      while(selectedItems.isNotEmpty) {
        final IdWrapper item = selectedItems[0];
        await _api.items.restore(item.id);
        items.removeAt(0);
      }
    });
    await refresh();
  }

  void itemSelectChanged() {
    setActions();
  }

  @override
  void ngOnDestroy() {
    _searchSubscription.cancel();
    _pageActionSubscription.cancel();
    _authChangedSubscription.cancel();
    pageControl.reset();
  }

  @override
  void ngOnInit() {
    _searchSubscription = pageControl.searchChanged.listen(onSearchChanged);
    _authChangedSubscription =
        _auth.authStatusChanged.listen(onAuthStatusChange);
    _pageActionSubscription =
        pageControl.pageActionRequested.listen(onPageActionRequested);
    refresh();
  }

  Future<Null> onAuthChanged(bool status) async {
    await refresh();
    setActions();
  }

  Future<Null> onAuthStatusChange(bool value) async {
    await this.refresh();
  }

  void onPageActionRequested(PageAction action) {
    switch (action) {
      case PageAction.refresh:
        this.refresh();
        break;
      case PageAction.delete:
        this.deleteSelected();
        break;
      case PageAction.openInNew:
        this.openSelectedItemsInNewWindow();
        break;
      case PageAction.tag:
        this.openSelectedItemsInNewWindow();
        break;
      case PageAction.restore:
        this.restoreSelected();
      break;
      default:
        throw new Exception(
            action.toString() + " not implemented for this page");
    }
  }

  void onSearchChanged(String query) {
    if (_currentQuery != query) {
      this._currentQuery = query;
      _router.navigate([
        itemsSearchRoute.name,
        {queryRouteParameter: query}
      ]);
    }
  }

  Future<Null> openSelectedItemsInNewWindow() async {
    try {
      final Queue<IdWrapper> toOpen = new Queue<IdWrapper>.from(selectedItems);

      Future<Null> openNextLink(dynamic event) async {
        try {
          if (toOpen.isEmpty) return;
          final IdWrapper item = toOpen.removeFirst();
          //final AnchorElement a =document.getElementById("original_link_${item.id}");
          //if (a != null) {
          final String link = getImageUrl(item.id, ItemFileType.full);
          final WindowBase wb = window.open(link, item.id);
          wb.addEventListener('load', openNextLink, true);
          //a.click();
          //}
        } catch (e, st) {
          handleException(e, st);
        }
      }

      await openNextLink(null);
    } catch (e, st) {
      handleException(e, st);
    }
  }

  Future<Null> refresh() async {
    await performApiCall(() async {
      int page = 0;
      String query = "";
      String routeName = itemsPageRoute.name;
      if (_routeParams.params.containsKey(pageRouteParameter)) {
        page = int.parse(_routeParams.get(pageRouteParameter) ?? '1',
            onError: (_) => 1) -
            1;
      }
      if (_routeParams.params.containsKey(queryRouteParameter)) {
        query = _routeParams.get(queryRouteParameter);
      }

      if (isNotNullOrWhitespace(query)) {
        final TagList tagList = new TagList.fromQueryString(query);
        _search.setTags(tagList);
        routeName = itemsSearchPageRoute.name;
      } else {
        _search.clearTags();
      }

      final PaginatedItemResponse response =
      await _search.performSearch(page: page, inTrash: true);

      selectedItems.clear();
      items.clear();
      if (response.items.isNotEmpty)
        items.addAll(response.items.map((String id) => new IdWrapper(id)));

      final PaginationInfo info = new PaginationInfo();
      for (int i = 0; i < response.totalPages; i++) {
        final Map<String, String> params = <String, String>{};
        if (isNotNullOrWhitespace(query)) {
          params[queryRouteParameter] = query;
        }
        params[pageRouteParameter] = (i + 1).toString();
        info.pageParams.add([routeName, params]);
      }
      info.currentPage = page;
      pageControl.setPaginationInfo(info);
    });
  }

  void setActions() {
    final List<PageAction> actions = <PageAction>[];
    if (selectedItems.isNotEmpty) {
      actions.add(PageAction.delete);
      actions.add(PageAction.restore);
      // Can't open multiple windows, so this doesn't work right now
      //actions.add(PageActions.OpenInNew);
    }
    actions.add(PageAction.refresh);
//    if (_auth.hasPrivilege(UserPrivilege.normal)) {
//      actions.add(PageActions.Add);
//    }
    pageControl.setAvailablePageActions(actions);
  }

}
