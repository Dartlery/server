import 'dart:async';
import 'dart:html' as html;

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:dartlery/api/api.dart' as api;
import 'package:dartlery/routes.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery/views/controls/item_upload_component.dart';
import 'package:dartlery/views/pages/pages.dart';
import 'package:dartlery_shared/global.dart';
import 'package:tools/tools.dart';
import 'package:logging/logging.dart';
import 'package:dartlery/views/controls/common_controls.dart';
import 'package:dartlery/data/data.dart' as data;
import 'package:lib_angular/angular.dart';

@Component(
    selector: 'main-app',
    //encapsulation: ViewEncapsulation.Native,
    templateUrl: 'main_app.html',
    styleUrls: const [
      'package:lib_angular/shared.css',
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
      libComponents,
      ButtonToolbarComponent
    ],
    providers: const [
      FORM_PROVIDERS,
      ROUTER_PROVIDERS,
      materialProviders,
      PageControlService,
      ItemSearchService,
      api.SettingsService,
      ApiService,
      AuthenticationService,
      const Provider(AAuthenticationService, useClass: AuthenticationService),
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

  bool userIsModerator = false;
  bool userIsAdmin = false;

  StreamSubscription<String> _pageTitleSubscription;
  StreamSubscription<String> _searchSubscription;
  StreamSubscription<MessageEventArgs> _messageSubscription;
  StreamSubscription<Null> _loginRequestSubscription;
  StreamSubscription<ProgressEventArgs> _progressSubscription;

  String _pageTitleOverride = "";

  String query = "";

  MainApp(this._auth, this._location, this._router, this._pageControl);

  data.User get currentUser => _auth.user.getOrDefault(null);

  String get pageTitle {
    if (isNotNullOrWhitespace(_pageTitleOverride)) {
      return _pageTitleOverride;
    } else {
      return appName;
    }
  }

  bool get userLoggedIn {
    return _auth.isAuthenticated;
  }

  ProgressEventArgs progressModel = new ProgressEventArgs();

  Future<Null> clearAuthentication() async {
    await _auth.clear();
    //await _router.navigate(<dynamic>["Home"]);
  }

  @override
  void ngOnDestroy() {
    _pageTitleSubscription.cancel();
    _loginRequestSubscription.cancel();
    _searchSubscription.cancel();
    _progressSubscription.cancel();
  }

  @override
  Future<Null> ngOnInit() async {
    _pageTitleSubscription =
        _pageControl.pageTitleChanged.listen(onPageTitleChanged);
    _loginRequestSubscription =
        _auth.loginPrompted.listen(promptForAuthentication);
    _searchSubscription = _pageControl.searchChanged.listen(onSearchChanged);
    _messageSubscription = _pageControl.messageSent.listen(onMessageSent);
    _progressSubscription =
        _pageControl.progressChanged.listen(onProgressChanged);

    try {
      await _auth.evaluateAuthentication();
    } on api.DetailedApiRequestError catch (e, st) {
      if (e.status == httpStatusServerNeedsSetup) {
        await _router.navigate([setupRoute.name]);
      } else {
        _log.severe("evaluateAuthentication", e, st);
        rethrow;
      }
    }
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

  void searchKeyup(html.KeyboardEvent e) {
    if (e.keyCode == html.KeyCode.ENTER) {
      _pageControl.search(query);
    }
  }

  Future<Null> tagSearchChanged(List<api.Tag> event) async {
    final String query = data.TagList.convertToQueryString(event);
    await _router.navigate([
      itemsSearchRoute.name,
      {queryRouteParameter: query}
    ]);
  }

  bool errorMessageVisible = false;
  String errorMessageHeader = "Error";
  String errorMessage = "Error message";

  void onMessageSent(MessageEventArgs e) {
    this.errorMessage = e.message;
    this.errorMessageHeader = e.title;
    this.errorMessageVisible = true;
  }

  void onProgressChanged(ProgressEventArgs e) {
    this.progressModel = e;
  }
}
