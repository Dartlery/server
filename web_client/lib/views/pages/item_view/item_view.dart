import 'dart:html' as html;
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery_shared/global.dart';
import 'dart:async';
import 'package:dartlery/client.dart';
import 'package:angular/angular.dart';
import 'dart:convert';
import 'package:angular_forms/angular_forms.dart';

import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/routes.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery/views/controls/auth_status_component.dart';
import 'package:dartlery/views/controls/error_output.dart';
import 'package:logging/logging.dart';
import '../src/a_page.dart';
import 'package:dartlery/views/controls/common_controls.dart';

@Component(
    selector: 'item-view',
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      materialDirectives,
      ROUTER_DIRECTIVES,
      AuthStatusComponent,
      ErrorOutputComponent,
      commonControls
    ],
    styleUrls: const <String>["../../shared.css", "item_view.css"],
    templateUrl: "item_view.html")
class ItemViewPage extends APage implements OnInit, OnDestroy {
  static final Logger _log = new Logger("ItemViewPage");

  NgForm form;
  final ItemSearchService _searchService;

  Item model = new Item();

  bool get isImage {
    return MimeTypes.imageTypes.contains(model?.mime)||model?.mime==MimeTypes.pdf;
  }

  bool get isVideo {
    return MimeTypes.videoTypes.contains(model?.mime);
  }

  ApiService _api;
  Router _router;
  AuthenticationService _auth;
  Location _location;
  RouteParams _params;

  String itemId;

  StreamSubscription<PageAction> _pageActionSubscription;

  ItemViewPage(PageControlService pageControl, this._api, this._auth,
      this._router, this._params, this._location, this._searchService)
      : super(_auth, _router, pageControl) {
    pageControl.setPageTitle("Item View");
    pageControl
        .setAvailablePageActions([PageAction.refresh, PageAction.delete]);
  }

  @override
  Logger get loggerImpl => _log;

  @override
  void ngOnInit() {
    final String _id = _params.get(idRouteParameter);
    if (isNullOrWhitespace(_id))
      throw new Exception("Empty ID passed");
    itemId = _id;
    _pageActionSubscription =
        pageControl.pageActionRequested.listen(onPageActionRequested);
    refresh();
  }

  @override
  void ngOnDestroy() {
    _pageActionSubscription.cancel();
  }

  void onPageActionRequested(PageAction action) {
    switch (action) {
      case PageAction.refresh:
        this.refresh();
        break;
      case PageAction.delete:
        delete();
        break;
      default:
        throw new Exception(
            action.toString() + " not implemented for this page");
    }
  }

  Future<Null> delete() async {
    pageControl.setIndeterminateProgress();
    await performApiCall(() async {
      model = await _api.items.delete(itemId);
      if (nextItemAvailable) {
        await _router.navigate([
          itemViewRoute.name,
          {"id": nextItem}
        ]);
      } else if (previousItemAvailable) {
        await _router.navigate([
          itemViewRoute.name,
          {"id": previousItem}
        ]);
      } else {
        await _router.navigate([homeRoute.name]);
      }
    }, after: () async {
      pageControl.clearProgress();
    });
  }

  Future<Null> refresh() async {
    pageControl.setIndeterminateProgress();
    await performApiCall(() async {
      model = await _api.items.getById(itemId);

      nextItem = await _searchService.getNextItem(model.id);
      previousItem = await _searchService.getPreviousItem(model.id);
    }, after: () async {
      pageControl.clearProgress();
    });
  }

  Future<Null> onSubmit() async {
    await performApiCall(() async {
      await refresh();
    }, form: form);
  }

  void clear() {}

  String nextItem;
  bool get nextItemAvailable => nextItem != null;
  String previousItem;
  bool get previousItemAvailable => previousItem != null;
}
