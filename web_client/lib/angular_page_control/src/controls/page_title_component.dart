import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:logging/logging.dart';
import '../page_control_service.dart';
import '../page_action.dart';

@Component(
    selector: 'page-title',
    styles: const [''],
    styleUrls: const [''],
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      coreDirectives,
      materialDirectives,
      routerDirectives
    ],
    template: '{{pageTitle}}')
class PageTitleComponent implements OnInit, OnDestroy {
  static final Logger _log = new Logger("PageTitleComponent");

  final PageControlService _pageControl;

  String defaultTitle = "Default title";

  String _pageTitleOverride = "";

  ProgressEventArgs progressModel = new ProgressEventArgs();

  StreamSubscription<String> _pageTitleSubscription;

  String get pageTitle {
    if (_pageTitleOverride?.length ?? 0 > 0) {
      return _pageTitleOverride;
    } else {
      return defaultTitle;
    }
  }

  PageTitleComponent(this._pageControl);

  @override
  Future<Null> ngOnInit() async {
    _pageTitleSubscription =
        _pageControl.pageTitleChanged.listen(onPageTitleChanged);
  }

  @override
  void ngOnDestroy() {
    _pageTitleSubscription.cancel();
  }

  void onPageTitleChanged(String title) {
    this._pageTitleOverride = title;
  }
}
