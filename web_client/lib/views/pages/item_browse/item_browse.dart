import 'dart:collection';
import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
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
import 'package:dartlery/angular_page_control/angular_page_control.dart';

@Component(
    selector: 'item-browse',
    providers: const [materialProviders],
    directives: const [
      CORE_DIRECTIVES,
      materialDirectives,
      ROUTER_DIRECTIVES,
      AuthStatusComponent,
      TagEntryComponent,
      ItemGrid
    ],
    styleUrls: const ["../../shared.css", 'item_browse.css'],
    templateUrl: 'item_browse.html')
class ItemBrowseComponent extends APage implements OnInit, OnDestroy {
  static final Logger _log = new Logger("ItemBrowseComponent");
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

  StreamSubscription<PageActionEventArgs> _pageActionSubscription;
  StreamSubscription<bool> _authChangedSubscription;

  List<Tag> palletTags = <Tag>[];

  final ItemSearchService _search;

  String get currentRssLink => _search.getCurrentFeedUrl();

  String get currentRandomRssLink => _search.getCurrentRandomFeedUrl();

  ItemBrowseComponent(
      this._api,
      this._routeParams,
      PageControlService pageControl,
      this._router,
      this._auth,
      this._search,
      this._routeData)
      : super(_auth, _router, pageControl) {
    setActions();
  }

  @override
  Logger get loggerImpl => _log;

  bool get noItemsFound => items.isEmpty;

  List<IdWrapper> get selectedItems =>
      items.where((IdWrapper item) => item.selected).toList();

  Future<Null> deleteSelected() async {
    if (selectedItems.isEmpty) return;
    pageControl.setProgress(0, max: selectedItems.length);
    int i = 1;
    for (IdWrapper item in selectedItems) {
      await performApiCall(() async {
        await _api.items.delete(item.id);
        pageControl.setProgress(i, max: selectedItems.length);
        i++;
      });
    }
    await refresh();
  }

  bool get viewingTrash {
    return _routeData?.data["trash"] ?? false;
  }

  Tag _draggingTag;

  void palletTagDragStart(dynamic event, Tag t) {
    _draggingTag = t;
    final String query = tagToQueryString(t);
    event.dataTransfer.setData("text", query);
  }

  Future<Null> droppedOnItem(ItemGridDropEventArgs e) async {
    final String query = e.mouseEvent.dataTransfer.getData("text");
    final TagList tagList = new TagList.fromQueryString(query);
    final TagWrapper tag = tagList.first;

    await applyTagWrappersToItem(e.id, [tag]);
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

  void onPageActionRequested(PageActionEventArgs e) {
    switch (e.action) {
      case PageAction.refresh:
        this.refresh();
        break;
      case PageAction.delete:
        if (e.value ?? false) this.deleteSelected();
        break;
      case PageAction.openInNew:
        this.openSelectedItemsInNewWindow();
        break;
      case PageAction.tag:
        this.openSelectedItemsInNewWindow();
        break;

      default:
        throw new Exception(
            e.action.toString() + " not implemented for this page");
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
      pageControl.setIndeterminateProgress();
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
          await _search.performSearch(page: page, inTrash: viewingTrash);

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
    }, after: () async {
      pageControl.clearProgress();
    });
  }

  void setActions() {
    final List<PageAction> actions = <PageAction>[
      PageAction.refresh,
      //PageActions.Search
    ];
    if (selectedItems.isNotEmpty) {
      actions.add(PageAction.delete);
      // Can't open multiple windows, so this doesn't work right now
      //actions.add(PageActions.OpenInNew);
    }
//    if (_auth.hasPrivilege(UserPrivilege.normal)) {
//      actions.add(PageActions.Add);
//    }
    pageControl.setAvailablePageActions(actions);
  }

  Future<Null> tagSelected() async {
    for (IdWrapper id in selectedItems) {
      await applyTagsToItem(id.id, palletTags);
    }
  }

  Future<Null> applyTagWrappersToItem(String id, List<TagWrapper> tags) =>
      applyTagsToItem(id, tags.map((tw) => tw.tag));

  Future<Null> applyTagsToItem(String id, List<Tag> tags) async {
    await performApiCall(() async {
      final TagList newTags =
          new TagList.fromTags(await _api.items.getTagsByItemId(id));
      newTags.addTags(tags);
      await _api.items.updateTagsForItemId(newTags.toListOfTag(), id);
    });
  }
}
