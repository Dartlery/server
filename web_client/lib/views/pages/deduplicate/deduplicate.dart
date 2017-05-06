import 'package:dartlery_shared/tools.dart';
import 'package:dartlery_shared/global.dart';
import 'dart:html' as html;
import 'dart:async';
import 'package:dartlery/client.dart';
import 'package:angular2/angular2.dart';
import 'package:angular2/platform/common.dart';
import 'dart:convert';

import 'package:angular2/router.dart';
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
    selector: 'deduplicate-page',
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      materialDirectives,
      ROUTER_DIRECTIVES,
      AuthStatusComponent,
      ErrorOutputComponent,
      commonControls
    ],
    styleUrls: const <String>["../../shared.css"],
    templateUrl: "deduplicate.html")
class DeduplicatePage extends APage implements OnInit, OnDestroy {
  static final Logger _log = new Logger("DeduplicatePage");

  NgForm form;

  ExtensionData model;

  String get comparisonHeight {
    return "${html.window.innerHeight-225}px";
  }

  int currentImage = 0;

  String get currentImageUrl {
    if(model==null)
      return "";
    if(currentImage==0) {
      return getOriginalFileUrl(model.primaryId);
    } else {
      return getOriginalFileUrl(model.secondaryId);
    }
  }

  PageControlService _pageControl;
  ApiService _api;
  Router _router;
  AuthenticationService _auth;
  Location _location;
  RouteParams _params;

  String itemId;

  StreamSubscription<PageActions> _pageActionSubscription;

  DeduplicatePage(this._pageControl, this._api, this._auth, this._router, this._params, this._location)
      : super(_auth, _router) {
    _pageControl.setPageTitle("Deduplicate");
    _pageControl.setAvailablePageActions([PageActions.Refresh]);

  }

  @override
  Logger get loggerImpl => _log;

  @override
  void ngOnInit() {
    final String _id = _params.get(idRouteParameter);
    itemId = _id;
    _pageActionSubscription =
        _pageControl.pageActionRequested.listen(onPageActionRequested);
    refresh();
  }


  @override
  void ngOnDestroy() {
    _pageActionSubscription.cancel();
  }


  void onPageActionRequested(PageActions action) {
    switch (action) {
      case PageActions.Refresh:
        this.refresh();
        break;
      default:
        throw new Exception(
            action.toString() + " not implemented for this page");
    }
  }

  Future<Null> delete() async {
    await performApiCall(() async {
        model = await _api.items.delete(itemId);
        _location.back();
    });
  }

  Future<Null> refresh() async {
    await performApiCall(() async {
        clear();
        final ExtensionDataPaginatedResponse response= await _api.extensionData.get("itemComparison", "similarItems", orderByValues: true, orderDescending: true, perPage: 1);
        if(response.items.isNotEmpty)
          model = response.items.first;
    });
  }

  Future<Null> onSubmit() async {
    await performApiCall(() async {
        await refresh();
    }, form:  form);
  }

  void clear() {
    model = null;
  }
}
