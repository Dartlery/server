
import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:logging/logging.dart';
import '../page_control_service.dart';
import '../page_action.dart';

@Component(
    selector: 'page-progress',
    styles: const [''],
    styleUrls: const [''],
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[CORE_DIRECTIVES, materialDirectives, ROUTER_DIRECTIVES],
    template: '''
            <material-progress *ngIf="progressModel.show" class="fit" [indeterminate]="progressModel.indeterminate"
                           [activeProgress]="progressModel.value" [min]="progressModel.min" [max]="progressModel.max">
        </material-progress>
    ''')
class PageProgressComponent implements OnInit, OnDestroy {
  static final Logger _log = new Logger("PageProgressComponent");

  final PageControlService _pageControl;

  ProgressEventArgs progressModel = new ProgressEventArgs();

  StreamSubscription<ProgressEventArgs> _progressSubscription;


  PageProgressComponent(this._pageControl);

  @override
  Future<Null> ngOnInit() async {
    _progressSubscription = _pageControl.progressChanged.listen(onProgressChanged);
  }
  @override
  void ngOnDestroy() {
    _progressSubscription.cancel();
  }

  void onProgressChanged(ProgressEventArgs e) {
    this.progressModel = e;
  }

}
