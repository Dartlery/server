import 'dart:async';

import 'package:angular2/angular2.dart';
import 'package:angular2/router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/services/services.dart';
import 'package:logging/logging.dart';

@Component(
    selector: 'paginator',
    styles: const [
      'div.paginator { position:fixed; background-color:white; bottom: 8pt; right:8pt; margin-left:8pt;}'
    ],
    directives: const [ROUTER_DIRECTIVES, materialDirectives],
    providers: const [materialProviders],
    template: '''
    <div class="paginator" *ngIf="pages.isNotEmpty" >
    <material-button *ngIf="isNotFirstPage" icon [routerLink]="previousPageRoute"><glyph icon="chevron_left" ></glyph></material-button>
    <material-button *ngFor="let p of pages" [routerLink]="p.route" style=""><span style="font-size:14pt;">{{p.page}}</span></material-button>
    <material-button *ngIf="isNotLastPage" icon [routerLink]="nextPageRoute"><glyph icon="chevron_right" ></glyph></material-button>
    </div>
    ''')
class PaginatorComponent implements OnDestroy {
  static final Logger _log = new Logger("PaginatorComponent");

  int currentPage;

  final List<_PaginatorEntry> pages = <_PaginatorEntry>[];
  final List<dynamic> pageRoutes = <dynamic>[];

  final PageControlService _pageControl;
  StreamSubscription<PaginationInfo> _subscription;

  PaginatorComponent(this._pageControl) {
    _subscription = _pageControl.paginationChanged.listen(onSubscriptionUpdate);
  }

  bool get isNotFirstPage => currentPage > 0;

  bool get isNotLastPage => currentPage < pageRoutes.length - 1;

  dynamic get nextPageRoute {
    if (isNotLastPage) {
      return pageRoutes[currentPage + 1];
    }
    return null;
  }

  dynamic get previousPageRoute {
    if (isNotFirstPage) {
      return pageRoutes[currentPage - 1];
    }
    return null;
  }

  @override
  void ngOnDestroy() {
    _subscription.cancel();
  }

  static const int pageRange = 3;

  void onSubscriptionUpdate(PaginationInfo status) {
    pages.clear();
    pageRoutes.clear();
    currentPage = status.currentPage;
    if (status.pageParams.length <= 1) return;
    pageRoutes.addAll(status.pageParams);

    for (int i = 0; i < status.pageParams.length; i++) {
      if (i != 0 &&
          i != status.pageParams.length - 1 &&
          (i < currentPage - pageRange || i > currentPage + pageRange)) {
        continue;
      }

      final _PaginatorEntry entry = new _PaginatorEntry();
      entry.page = i + 1;
      entry.route = status.pageParams[i];
      pages.add(entry);
    }
  }
}

class _PaginatorEntry {
  int page;
  dynamic route;
}
