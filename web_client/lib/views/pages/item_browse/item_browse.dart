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
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';

import '../src/a_page.dart';

class IdWrapper {
  String id;
  bool selected = false;

  IdWrapper(this.id);
}

@Component(
    selector: 'item-browse',
    providers: const [materialProviders],
    directives: const [
      materialDirectives,
      ROUTER_DIRECTIVES,
      AuthStatusComponent,
    ],
    styleUrls: const ["../../shared.css", "item_browse.css"],
    templateUrl: 'item_browse.html')
class ItemBrowseComponent extends APage implements OnInit, OnDestroy {
  static final Logger _log = new Logger("ItemBrowseComponent");
  bool curatorAuth = false;

  bool userLoggedIn;
  final ApiService _api;
  final RouteParams _routeParams;
  final PageControlService _pageControl;
  final Router _router;
  final AuthenticationService _auth;
  final List<IdWrapper> items = <IdWrapper>[];
  String _currentQuery = "";

  StreamSubscription<String> _searchSubscription;

  StreamSubscription<PageActions> _pageActionSubscription;
  StreamSubscription<bool> _authChangedSubscription;
  StreamSubscription<KeyboardEvent> _keyboardSubscription;

  ItemBrowseComponent(
      this._api, this._routeParams, this._pageControl, this._router, this._auth)
      : super(_auth, _router) {
    setActions();
  }

  @override
  Logger get loggerImpl => _log;

  bool get noItemsFound => items.isEmpty;

  List<IdWrapper> get selectedItems =>
      items.where((IdWrapper item) => item.selected).toList();

  Future<Null> deleteSelected() async {
    if (selectedItems.isEmpty) return;
    for (IdWrapper item in selectedItems) {
      await performApiCall(() async {
        await _api.items.delete(item.id);
      });
    }
    await refresh();
  }

  String getOriginalFileUrl(String id) => getImageUrl(id, ImageType.original);

  String getThumbnailForImage(String value) {
    final String output = getImageUrl(value, ImageType.thumbnail);
    return output;
  }

  void itemSelectChanged(bool checked, String id) {
    setActions();
  }

  @override
  void ngOnDestroy() {
    _searchSubscription.cancel();
    _pageActionSubscription.cancel();
    _authChangedSubscription.cancel();
    _keyboardSubscription.cancel();
    _pageControl.reset();
  }

  @override
  void ngOnInit() {
    _searchSubscription = _pageControl.searchChanged.listen(onSearchChanged);
    _authChangedSubscription =
        _auth.authStatusChanged.listen(onAuthStatusChange);
    _pageActionSubscription =
        _pageControl.pageActionRequested.listen(onPageActionRequested);

    _keyboardSubscription = window.onKeyUp.listen(onKeyboardEvent);
    refresh();
  }

  Future<Null> onAuthChanged(bool status) async {
    await refresh();
    setActions();
  }

  Future<Null> onAuthStatusChange(bool value) async {
    await this.refresh();
  }

  void onKeyboardEvent(KeyboardEvent e) {
    if (e.keyCode == KeyCode.A && e.ctrlKey) {
      for (IdWrapper item in items) {
        item.selected = true;
      }
    }
  }

  void onPageActionRequested(PageActions action) {
    switch (action) {
      case PageActions.Refresh:
        this.refresh();
        break;
      case PageActions.Delete:
        this.deleteSelected();
        break;
      case PageActions.OpenInNew:
        this.openSelectedItemsInNewWindow();
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

  Future<Null> openSelectedItemsInNewWindow() async{
    try {
      final Queue<IdWrapper> toOpen = new Queue<IdWrapper>.from(selectedItems);


      Future<Null>openNextLink(dynamic event) async {
        try {
          if (toOpen.isEmpty)
            return;
          final IdWrapper item = toOpen.removeFirst();
          //final AnchorElement a =document.getElementById("original_link_${item.id}");
          //if (a != null) {
            final String link = getImageUrl(item.id, ImageType.original);
            final WindowBase wb = window.open(link, item.id);
            wb.addEventListener('load', openNextLink, true);
            //a.click();
          //}
        } catch(e,st) {
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

      PaginatedResponse response;
      if (StringTools.isNullOrWhitespace(query)) {
        response = await _api.items.getVisibleIds(page: page);
      } else {
        final TagList tagList = new TagList.fromQueryString(query);

        final ItemSearchRequest request = new ItemSearchRequest();
        request.page = page;
        request.tags = tagList.toListOfTags();

        response = await _api.items.searchVisible(request);
        routeName = itemsSearchPageRoute.name;
      }

      selectedItems.clear();
      items.clear();
      if (response.items.isNotEmpty)
        items.addAll(response.items.map((String id) => new IdWrapper(id)));

      final PaginationInfo info = new PaginationInfo();
      for (int i = 0; i < response.totalPages; i++) {
        final Map<String, String> params = <String, String>{};
        if (StringTools.isNotNullOrWhitespace(query)) {
          params[queryRouteParameter] = query;
        }
        params[pageRouteParameter] = (i + 1).toString();
        info.pageParams.add([routeName, params]);
      }
      info.currentPage = page;
      _pageControl.setPaginationInfo(info);
    });
  }

  void setActions() {
    final List<PageActions> actions = <PageActions>[
      PageActions.Refresh,
      //PageActions.Search
    ];
    if (selectedItems.isNotEmpty) {
      actions.add(PageActions.Delete);
      // Can't open multiple windows, so this doesn't work right now
      //actions.add(PageActions.OpenInNew);
    }
//    if (_auth.hasPrivilege(UserPrivilege.normal)) {
//      actions.add(PageActions.Add);
//    }
    _pageControl.setAvailablePageActions(actions);
  }
}
