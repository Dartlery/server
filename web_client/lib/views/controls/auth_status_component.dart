import 'dart:async';
import 'package:angular/angular.dart';
import 'package:dartlery/services/services.dart';
import 'package:logging/logging.dart';
import 'package:dartlery_shared/global.dart';

@Component(
    directives: coreDirectives,
    selector: 'auth-status',
    styleUrls: const ['../shared.css'],
    template:
        '<div *ngIf="showMessage&&!authorized" class="no-items">Access Denied</div>')
class AuthStatusComponent implements OnInit, OnDestroy {
  static final Logger _log = new Logger("AuthStatusComponent");

  @Input()
  bool showMessage = false;

  @Input()
  String required = UserPrivilege.normal;

  final StreamController<bool> _authorizedChangeController = new StreamController<bool>();
  @Output()
  Stream<bool> get authorizedChanged => _authorizedChangeController.stream;


  final AuthenticationService _auth;

  StreamSubscription<bool> _subscription;

  AuthStatusComponent(this._auth) {
    _subscription = _auth.authStatusChanged.listen(onAuthStatusChange);
  }

  void onAuthStatusChange(bool status) {
    _authorizedChangeController.add(authorized);
  }

  bool get authorized {
    if (!_auth.isAuthenticated) return false;
    return _auth.hasPrivilege(required);
  }

  @override
  void ngOnInit() {
    _authorizedChangeController.add(authorized);
  }

  @override
  void ngOnDestroy() {
    _subscription.cancel();
  }
}
