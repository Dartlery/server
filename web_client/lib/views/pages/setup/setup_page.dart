import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/routes.dart';
import 'package:dartlery/services/services.dart';
import 'package:logging/logging.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:lib_angular/angular.dart';
import 'package:lib_angular/views/views.dart';

@Component(
    selector: 'setup-page',
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      CORE_DIRECTIVES,
      materialDirectives,
      formDirectives,
      ROUTER_DIRECTIVES,
      AuthStatusComponent,
      ErrorOutputComponent
    ],
    styleUrls: const <String>["package:lib_angular/shared.css"],
    templateUrl: "setup_page.html")
class SetupPage extends APage<ApiService> implements OnInit {
  static final Logger _log = new Logger("SetupPage");

  @ViewChild("setupForm")
  NgForm form;

  SetupResponse status = new SetupResponse();
  SetupRequest request = new SetupRequest();
  String confirmPassword = "";

  Router _router;
  AuthenticationService _auth;

  SetupPage(
      PageControlService pageControl, ApiService api, this._auth, this._router)
      : super(api, _auth, _router, pageControl) {
    pageControl.setPageTitle("Setup");
  }

  @override
  Logger get loggerImpl => _log;

  @override
  void ngOnInit() {
    refresh();
  }

  Future<Null> refresh() async {
    await performApiCall(() async {
      try {
        //final SetupResponse response =
        await api.setup.get();
      } on DetailedApiRequestError catch (e, st) {
        loggerImpl.warning(e, st);
        if (e.status == 403) {
          // This indicates that setup is disabled, so we redirect to the main page and prompt for login
          await _router.navigate(<String>[homeRoute.name]);
          _auth.promptForAuthentication();
        } else {
          rethrow;
        }
      }
    });
  }

  Future<Null> onSubmit() async {
    try {
      // TODO: Figure out how to use angular's validators to do this on-the-fly
      if (request.adminPassword != confirmPassword) {
        final AbstractControl control = form.controls["confirmPassword"];
        control.setErrors(
            <String, String>{"confirmPassword": "Passwords must match"});
        return;
      }
      await performApiCall(() async {
        try {
          //final SetupResponse response =
          await api.setup.apply(request);
          await refresh();
        } on DetailedApiRequestError catch (e, st) {
          loggerImpl.warning(e, st);
          if (e.status == 403) {
            // This indicates that setup is disabled, so we redirect to the main page and prompt for login
            await _router.navigate(<String>[homeRoute.name]);
            _auth.promptForAuthentication();
          } else {
            rethrow;
          }
        }
      }, form: form);
    } catch (e, st) {
      setErrorMessage(e, st);
    }
  }

  void clear() {
    request = new SetupRequest();
    confirmPassword = "";
  }
}
