import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:logging/logging.dart';
import '../page_control_service.dart';
import '../page_action.dart';

@Component(
    selector: 'page-actions',
    styles: const [''],
    styleUrls: const [''],
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      CORE_DIRECTIVES,
      materialDirectives,
      ROUTER_DIRECTIVES
    ],
    template:
        '<material-button *ngFor="let a of availableActions" icon (trigger)="pageActionTriggered(a)"><glyph icon="{{a.icon}}"></glyph></material-button>')
class PageActionsComponent implements OnInit, OnDestroy {
  static final Logger _log = new Logger("PageActionsComponent");

  StreamSubscription<List> _pageActionsSubscription;
  final PageControlService _pageControl;

  final List<PageAction> availableActions = <PageAction>[];

  PageActionsComponent(this._pageControl);
  StreamSubscription<KeyboardEvent> _keyboardSubscription;

  @override
  Future<Null> ngOnInit() async {
    _keyboardSubscription = window.onKeyUp.listen(onKeyboardEvent);
    _pageActionsSubscription =
        _pageControl.availablePageActionsSet.listen(onPageActionsSet);
  }

  void onKeyboardEvent(KeyboardEvent e) {
    for(PageAction action in availableActions.where((action) => action.shortcut!=null)) {
      if (e.ctrlKey==action.shortcutCtrl && e.altKey==action.shortcutAlt && e.shiftKey==action.shortcutShit && e.keyCode == action.shortcut) {
        pageActionTriggered(action);
        break;
      }
    }
  }

  @override
  void ngOnDestroy() {
    _pageActionsSubscription.cancel();
    _keyboardSubscription.cancel();
  }

  void onPageActionsSet(List<PageAction> actions) {
    this.availableActions.clear();
    this.availableActions.addAll(actions);
  }

  Future<Null> pageActionTriggered(PageAction action) async {
    PageActionEventArgs e;
    if (action.message != null) {
      String id = _pageControl.sendMessage(action.message);
      ResponseEventArgs response = await _pageControl.responseSent
          .firstWhere((ResponseEventArgs e) => e.id == id);
      e = new PageActionEventArgs(action, value: response.value);
    } else {
      e = new PageActionEventArgs(action);
    }
    _pageControl.requestPageAction(e);
  }
}
