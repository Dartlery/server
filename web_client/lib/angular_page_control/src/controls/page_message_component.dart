
import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:logging/logging.dart';
import '../page_control_service.dart';
import '../page_message.dart';

@Component(
    selector: 'page-messages',
    styles: const [''],
    styleUrls: const [''],
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[CORE_DIRECTIVES, materialDirectives, ROUTER_DIRECTIVES],
    template: '''
<modal [visible]="visible">
    <material-dialog class="basic-dialog">
        <h3 header>{{message?.title}}</h3>
        <p>
            {{message?.message}}
        </p>
        <div footer style="text-align: right">
            <material-button *ngFor="let b of message?.buttons?.text; let i=index" (trigger)="buttonPress(i)">{{b.text}}</material-button>
        </div>
    </material-dialog>
</modal>    ''')
class PageMessageComponent implements OnInit, OnDestroy {
  static final Logger _log = new Logger("PageMessageComponent");

  final PageControlService _pageControl;

  PageMessage message;
  String messageId;
  bool visible = false;

  void onMessageSent(MessageEventArgs e) {
    this.message = e.message;
    this.messageId = e.id;
    this.visible = true;
  }

  StreamSubscription<MessageEventArgs> _messageSubscription;

  PageMessageComponent(this._pageControl);

  @override
  Future<Null> ngOnInit() async {
    _messageSubscription = _pageControl.messageSent.listen(onMessageSent);
  }

  @override
  void ngOnDestroy() {
    _messageSubscription.cancel();
  }

  void buttonPress(int index) {
    visible = false;
    ResponseEventArgs e = new ResponseEventArgs(message, messageId, message.buttons.text[index].value);
    _pageControl.sendResponse(e);
  }
}
