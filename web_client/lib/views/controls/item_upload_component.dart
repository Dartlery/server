import 'dart:async';
import 'dart:html';
import 'package:dartlery/routes.dart';
import 'package:angular2/angular2.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import 'package:angular2/router.dart';
import '../src/a_error_thing.dart';
import 'package:dartlery_shared/global.dart';

@Component(
    selector: 'item-upload',
    styleUrls: const ['../shared.css'],
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      materialDirectives
    ],
    template: '''<modal [visible]="visible">
      <material-dialog class="basic-dialog">
          <h3 header>Upload</h3>
            <form (ngSubmit)="onSubmit()" #loginForm="ngForm">
            <p>
              <input type="file" />
              <error-output [error]="errorMessage"></error-output>
              <input type="submit" style="position: absolute; left: -9999px; width: 1px; height: 1px;"/>
          </p>
            </form>
          <div footer style="text-align: right">
            <material-yes-no-buttons yesHighlighted
            yesText="Login" (yes)="onSubmit()"
            noText="Cancel" (no)="visible = false"
            [pending]="processing" [yesDisabled]="!loginForm.valid">
            </material-yes-no-buttons>

          </div>
      </material-dialog>
    </modal>''')
class ItemUploadComponent extends AErrorThing {
  static final Logger _log = new Logger("ItemUploadComponent");

  String userName = "";

  String password = "";
  bool _visible = false;

  @Output()
  EventEmitter<bool> visibleChange = new EventEmitter<bool>();

  final Router _router;
  final AuthenticationService _auth;

  bool processing = false;

  ItemUploadComponent(this._auth, this._router);


  bool get hasErrorMessage => StringTools.isNotNullOrWhitespace(errorMessage);

  @override
  Logger get loggerImpl => _log;

  bool get visible => _visible;

  @Input()
  set visible(bool value) {
    reset();
    if (value) {
      processing = false;
    }
    _visible = value;
    visibleChange.emit(_visible);
  }

  Future<Null> onSubmit() async {
    errorMessage = "";
    processing = true;
    try {
      await _auth.authenticate(userName, password);
      visible = false;
    } on Exception catch (e, st) {
      setErrorMessage(e, st);
    } catch (e, st) {
      _log.severe(e, st);
      final HttpRequest request = e.target;
      if (request != null) {
        String message;
        switch (request.status) {
          case 401:
            message = "Login incorrect";
            break;
          case httpStatusServerNeedsSetup:
            await _router.navigate([setupRoute.name]);
            break;
          default:
            message = "${request.status} - ${request.statusText} - ${request
                .responseText}";
            break;
        }
        errorMessage = message;
      } else {
        errorMessage = "Unknown error while authenticating";
      }
    } finally {
      processing = false;
    }
  }

  void reset() {
    userName = "";
    password = "";
    errorMessage = "";
  }

}