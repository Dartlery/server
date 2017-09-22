import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/routes.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery/views/controls/auth_status_component.dart';
import 'package:dartlery/views/controls/error_output.dart';
import 'package:logging/logging.dart';
import '../src/a_page.dart';

@Component(
    selector: 'import-page',
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      materialDirectives,
      ROUTER_DIRECTIVES,
      AuthStatusComponent,
      ErrorOutputComponent
    ],
    styleUrls: const <String>["../../shared.css"],
    styles: const <String>["table.importResults { user-select: text; } "],
    templateUrl: "import_page.html")
class ImportPage extends APage implements OnInit, OnDestroy {
  static final Logger _log = new Logger("ImportPage");

  ApiService _api;
  AuthenticationService _auth;

  ImportPathRequest request = new ImportPathRequest()..interpretShimmieNames=true;

  List<ImportResult> results = <ImportResult>[];



  ImportPage(PageControlService pageControl, this._api, this._auth, Router router)
      : super(_auth, router, pageControl) {
    pageControl.setPageTitle("Import");
    pageControl.setAvailablePageActions([PageAction.refresh]);
  }

  @override
  Logger get loggerImpl => _log;

  @override
  void ngOnInit() {
    _pageActionSubscription =
        pageControl.pageActionRequested.listen(onPageActionRequested);
    refresh();
  }
  StreamSubscription<PageAction> _pageActionSubscription;

  @override
  void ngOnDestroy() {
    _pageActionSubscription.cancel();
  }

  void onPageActionRequested(PageAction action) {
    switch (action) {
      case PageAction.refresh:
        this.refresh();
        break;
      default:
        throw new Exception(
            action.toString() + " not implemented for this page");
    }
  }
  Future<Null> refresh() async {
    pageControl.setIndeterminateProgress();
    await performApiCall(() async {
      results = (await _api.import.getResults()).items;
    }, after: () async {
      pageControl.clearProgress();
    });
  }

  Future<Null> clearSuccessResults() async {
    await performApiCall(() async {
      await _api.import.clearResults();
    });
    await refresh();
  }

  Future<Null> clearAllResults() async {
    await performApiCall(() async {
      await _api.import.clearResults(everything: true);
    });
    await refresh();
  }
  Future<Null> beginImport() async {
    await performApiCall(() async {
      await _api.import.importFromPath(request);
    });
  }

}
