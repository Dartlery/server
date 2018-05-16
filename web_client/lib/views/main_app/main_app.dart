import 'dart:async';
import 'dart:html' as html;

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/routes.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery/views/controls/login_form_component.dart';
import 'package:dartlery/angular_page_control/src/paginator_component.dart';
import 'package:dartlery/views/controls/item_upload_component.dart';
import 'package:dartlery/views/pages/pages.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import 'package:dartlery/views/controls/common_controls.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/angular_page_control/angular_page_control.dart';

@Component(
    selector: 'main-app',
    //encapsulation: ViewEncapsulation.Native,
    templateUrl: 'main_app.html',
    styleUrls: const [
      '../shared.css',
      'main_app.css',
      'package:angular_components/src/components/app_layout/layout.scss.css'
    ],
    directives: const [
      CORE_DIRECTIVES,
      ROUTER_DIRECTIVES,
      materialDirectives,
      pageDirectives,
      LoginFormComponent,
      ItemUploadComponent,
      PaginatorComponent,
      commonControls,
      pageControlComponents
    ],
    providers: const [
      FORM_PROVIDERS,
      ROUTER_PROVIDERS,
      materialProviders,
      PageControlService,
      ItemSearchService,
      SettingsService,
      ApiService,
      AuthenticationService,
      const Provider(APP_BASE_HREF, useValue: "/"),
      const Provider(LocationStrategy, useClass: HashLocationStrategy),
    ])
@RouteConfig(routes)
class MainApp implements OnInit, OnDestroy {
  static final Logger _log = new Logger("MainApp");

  final AuthenticationService _auth;

  final Location _location;
  final Router _router;
  final PageControlService _pageControl;
  bool isLoginOpen = false;
  bool isUploadOpen = false;

  bool showSearchBar = false;

  bool userIsModerator = false;
  bool userIsAdmin = false;

  StreamSubscription<String> _searchSubscription;
  StreamSubscription<Null> _loginRequestSubscription;

  String query = "";

  MainApp(this._auth, this._location, this._router, this._pageControl) {
    _loginRequestSubscription =
        _auth.loginPrompted.listen(promptForAuthentication);
    _searchSubscription = _pageControl.searchChanged.listen(onSearchChanged);
  }

  User get currentUser => _auth.user.getOrDefault(null);

  bool get showSearch => availableActions.contains(PageAction.search);

  final List<PageAction> availableActions = <PageAction>[];

  bool get userLoggedIn {
    return _auth.isAuthenticated;
  }

  PageAction confirmingAction;

  Future<Null> clearAuthentication() async {
    await _auth.clear();
    //await _router.navigate(<dynamic>["Home"]);
  }

  @override
  void ngOnDestroy() {
    _pageActionsSubscription.cancel();
    _loginRequestSubscription.cancel();
    _searchSubscription.cancel();
  }

  StreamSubscription<List> _pageActionsSubscription;

  @override
  Future<Null> ngOnInit() async {
    _pageActionsSubscription =
        _pageControl.availablePageActionsSet.listen(onPageActionsSet);

    try {
      await _auth.evaluateAuthentication();
    } on DetailedApiRequestError catch (e, st) {
      if (e.status == httpStatusServerNeedsSetup) {
        await _router.navigate([setupRoute.name]);
      } else {
        _log.severe("evaluateAuthentication", e, st);
        rethrow;
      }
    }
  }

  void onPageActionsSet(List<PageAction> actions) {
    this.availableActions.clear();
    this.availableActions.addAll(actions);
  }

  void onSearchChanged(String query) {
    this.query = query;
  }

  void promptForAuthentication([Null nullValue = null]) {
    isLoginOpen = true;
  }

  void openUploadWindow() {
    isUploadOpen = true;
  }

  void searchKeyup(html.KeyboardEvent e) {
    if (e.keyCode == html.KeyCode.ENTER) {
      _pageControl.search(query);
    }
  }

  Future<Null> tagSearchChanged(List<Tag> event) async {
    final String query = TagList.convertToQueryString(event);
    await _router.navigate([
      itemsSearchRoute.name,
      {queryRouteParameter: query}
    ]);
  }

  bool sideNavOpen = false;

  void navBarIconClicked() {
    sideNavOpen = !sideNavOpen;
  }
}
