import 'dart:async';
import 'dart:html' as html;

import 'package:angular2/angular2.dart';
import 'package:angular2/platform/common.dart';
import 'package:angular2/router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/routes.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery/views/controls/auth_status_component.dart';
import 'package:dartlery/views/controls/login_form_component.dart';
import 'package:dartlery/views/controls/paginator_component.dart';
import 'package:dartlery/views/controls/item_upload_component.dart';

import 'package:dartlery/views/pages/pages.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import 'package:polymer_elements/iron_flex_layout/classes/iron_flex_layout.dart';
import 'package:polymer_elements/iron_icon.dart';
import 'package:polymer_elements/iron_image.dart';
import 'package:polymer_elements/paper_drawer_panel.dart';
import 'package:polymer_elements/paper_header_panel.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_item_body.dart';
import 'package:polymer_elements/paper_material.dart';
import 'package:polymer_elements/paper_toolbar.dart';
import 'package:dartlery/views/controls/common_controls.dart';
import 'package:dartlery/data/data.dart';
@Component(
    selector: 'main-app',
    //encapsulation: ViewEncapsulation.Native,
    templateUrl: 'main_app.html',
    styleUrls: const [
      '../shared.css',
      'main_app.css'
    ],
    directives: const [
      ROUTER_DIRECTIVES,
      materialDirectives,
      pageDirectives,
      LoginFormComponent,
      ItemUploadComponent,
      PaginatorComponent,
      commonControls
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

  bool showRefreshButton = false;
  bool showAddButton = false;
  bool showSearch = false;
  bool showDeleteButton = false;
  bool showTagButton = false;
  bool showOpenInNewButton = false;

  bool userIsModerator = false;
  bool userIsAdmin = false;

  StreamSubscription<String> _pageTitleSubscription;
  StreamSubscription<String> _searchSubscription;
  StreamSubscription<List> _pageActionsSubscription;
  StreamSubscription<Null> _loginRequestSubscription;

  String _pageTitleOverride = "";

  String query = "";

  MainApp(this._auth, this._location, this._router, this._pageControl) {
    _pageTitleSubscription =
        _pageControl.pageTitleChanged.listen(onPageTitleChanged);
    _loginRequestSubscription =
        _auth.loginPrompted.listen(promptForAuthentication);
    _searchSubscription = _pageControl.searchChanged.listen(onSearchChanged);
    _pageActionsSubscription =
        _pageControl.availablePageActionsSet.listen(onPageActionsSet);
  }

  bool confirmDeleteVisible = false;

  User get currentUser => _auth.user.first;

  String get pageTitle {
    if (StringTools.isNotNullOrWhitespace(_pageTitleOverride)) {
      return _pageTitleOverride;
    } else {
      return appName;
    }
  }

  bool get userLoggedIn {
    return _auth.isAuthenticated;
  }

  void addClicked() {
    _pageControl.requestPageAction(PageActions.Add);
  }

  Future<Null> clearAuthentication() async {
    await _auth.clear();
    //await _router.navigate(<dynamic>["Home"]);
  }

  @override
  void ngOnDestroy() {
    _pageTitleSubscription.cancel();
    _loginRequestSubscription.cancel();
    _searchSubscription.cancel();
    _pageActionsSubscription.cancel();
  }

  @override
  Future<Null> ngOnInit() async {
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

  void onPageActionsSet(List<PageActions> actions) {
    showRefreshButton = actions.contains(PageActions.Refresh);
    showAddButton = actions.contains(PageActions.Add);
    showSearch = actions.contains(PageActions.Search);
    showDeleteButton = actions.contains(PageActions.Delete);
    showOpenInNewButton = actions.contains(PageActions.OpenInNew);
  }

  void onPageTitleChanged(String title) {
    this._pageTitleOverride = title;
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

  void refreshClicked() {
    _pageControl.requestPageAction(PageActions.Refresh);
  }
  void tagClicked() {
    _pageControl.requestPageAction(PageActions.Tag);
  }
  void deleteClicked() {
    confirmDeleteVisible = true;
  }

  void confirmDelete() {
    confirmDeleteVisible = false;
    _pageControl.requestPageAction(PageActions.Delete);
  }

  void openInNewClicked() {
    _pageControl.requestPageAction(PageActions.OpenInNew);
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

}
