import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:angular2/angular2.dart';
import 'package:angular2/platform/common.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular2/router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/client.dart';
import 'package:dartlery/routes.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery/views/controls/auth_status_component.dart';
import 'package:dartlery/views/controls/common_controls.dart';
import 'package:dartlery/views/controls/error_output.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import '../src/a_page.dart';

@Component(
    selector: 'deduplicate-page',
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      materialDirectives,
      ROUTER_DIRECTIVES,
      AuthStatusComponent,
      ErrorOutputComponent,
      commonControls
    ],
    styleUrls: const <String>["../../shared.css"],
    styles: const <String>[
      "span.win { color:green;}",
      "span.lose { color:red; }",
      "span.tie {color:orange; } "
    ],
    templateUrl: "deduplicate.html")
class DeduplicatePage extends APage implements OnInit, OnDestroy {
  static final Logger _log = new Logger("DeduplicatePage");

  ExtensionData model;
  Item firstComparisonItem = new Item();
  Item secondComparisonItem = new Item();

  int currentImage = 0;

  ApiService _api;

  Router _router;
  AuthenticationService _auth;

  Location _location;

  RouteParams _params;

  StreamSubscription<PageActions> _pageActionSubscription;
  String filterItemId;
  final NumberFormat f = new NumberFormat.decimalPattern();
  DeduplicatePage(PageControlService pageControl, this._api, this._auth, this._router,
      this._params, this._location)
      : super(_auth, _router, pageControl) {
    pageControl.setPageTitle("Deduplicate");
    pageControl.setAvailablePageActions([PageActions.Refresh]);
  }

  bool animatedComparison = true;

  String get comparisonHeight {
    return "${html.window.innerHeight-175}px";
  }
  String get comparisonWidth {
    return "${html.window.innerWidth}px";
  }

  double _comparisonSplitRatio = 0.5;

  int get comparisonSplitPositionInt {
    int x = (html.window.innerWidth * _comparisonSplitRatio).round();
    if(x<leftComparisonLimit)
      x = leftComparisonLimit;
    if(x>rightComparisonLimit)
      x=rightComparisonLimit;

    if(x<48)
      x = 48;
    return x;
  }
  String get comparisonSplitPosition {
    return "${comparisonSplitPositionInt}px";
  }

  @ViewChild("leftImage")
  html.ImageElement get leftImage => html.document.getElementById("leftImage");
  @ViewChild("rightImage")
  html.ImageElement get rightImage => html.document.getElementById("rightImage");

  int get leftComparisonLimit {
    return ((html.window.innerWidth/2) - (leftImage.offsetWidth/2)).round();
  }
  int get rightComparisonLimit {
    return ((html.window.innerWidth/2) + (rightImage.offsetWidth/2)).round();
  }

  void comparisonDrag(html.MouseEvent event) {
    animatedComparison = false;
    _log.info("Drag: ${event.offset.x}");
    final double adjustRatio = event.offset.x/html.window.innerWidth ;
    _comparisonSplitRatio += adjustRatio;
    event.preventDefault();
    event.stopPropagation();
  }


  String get currentImageUrl {
    if (model == null) return "";
    if (currentImage == 0) {
      return getFullFileUrl(firstComparisonItem);
    } else {
      return getFullFileUrl(secondComparisonItem);
    }
  }

  String get firstComparisonWidth => "${firstComparisonItem?.width??0}px";
  String get secondComparisonWidth => "${secondComparisonItem?.width??0}px";

  int get firstComparisonPixelCount =>
      (firstComparisonItem?.height ?? 0) * (firstComparisonItem?.width ?? 0);

  int get lengthWinner {
    if ((firstComparisonItem?.length ?? 0) >
        (secondComparisonItem?.length ?? 0)) {
      return 0;
    } else if ((firstComparisonItem?.length ?? 0) <
        (secondComparisonItem?.length ?? 0)) {
      return 1;
    }
    return -1;
  }

  /// true = right, false = left
  bool animationDirection = true;
  static const double _animationSpeed = 0.02; // TODO: Make this calculated against the amount of time between frames
  Future<Null> animationCallback(Timer t) async {
    if(animatedComparison&&model!=null&&firstComparisonItem!=null&&secondComparisonItem!=null) {
      if(animationDirection) { //right
        if(comparisonSplitPositionInt>leftComparisonLimit) {
          await wait();
          _comparisonSplitRatio -= _animationSpeed;
        } else {
          animationDirection = false;
        }
      } else { //left
        if(comparisonSplitPositionInt<rightComparisonLimit) {
          await wait();
          _comparisonSplitRatio += _animationSpeed;
        } else {
          animationDirection = true;
        }
      }
    }
  }


  @override
  Logger get loggerImpl => _log;

  int get secondComparisonPixelCount =>
      (secondComparisonItem?.height ?? 0) * (secondComparisonItem?.width ?? 0);

  int get sizeWinner {
    if (firstComparisonPixelCount > secondComparisonPixelCount) {
      return 0;
    } else if (firstComparisonPixelCount < secondComparisonPixelCount) {
      return 1;
    }
    return -1;
  }

  void clear() {
    model = null;
    firstComparisonItem = new Item();
    secondComparisonItem = new Item();
  }

  Future<Null> clearSimilarity() async {
    await performApiCall(() async {
      await _api.extensionData.delete(
          "itemComparison", "similarItems", model.primaryId, model.secondaryId);
      await refresh();
    });
  }

  Future<Null> deleteClicked(bool left) async {
    await performApiCall(() async {
      if (left) {
        await _api.items.delete(model.primaryId);
      } else {
        await _api.items.delete(model.secondaryId);
      }
      await refresh();
    });
  }

  Future<Null> mergeClicked(bool left) async {
    await performApiCall(() async {
      final IdRequest request = new IdRequest();
      if (left) {
        request.id = model.secondaryId;
        await _api.items.mergeItems(request, model.primaryId);
      } else {
        request.id = model.primaryId;
        await _api.items.mergeItems(request, model.secondaryId);
      }
      await refresh();
    });
  }

  Timer _comparisonTimer;

  @override
  void ngOnDestroy() {
    _pageActionSubscription.cancel();
    _comparisonTimer.cancel();
  }

  @override
  void ngOnInit() {
    final String _id = _params.get(idRouteParameter);
    filterItemId = _id;
    _pageActionSubscription =
        pageControl.pageActionRequested.listen(onPageActionRequested);
     refresh();

     new Timer(new Duration(seconds:1), () {
       _comparisonTimer = new Timer.periodic(new Duration(milliseconds: 100), animationCallback);
     });
  }


  void onPageActionRequested(PageActions action) {
    switch (action) {
      case PageActions.Refresh:
        this.refresh();
        break;
      default:
        throw new Exception(
            action.toString() + " not implemented for this page");
    }
  }

  Future<Null> refresh() async {
    await performApiCall(() async {
      clear();
      final PaginatedExtensionDataResponse response = await _api.extensionData
          .get("itemComparison", "similarItems",
              orderByValues: true, orderDescending: true, perPage: 1);
      if (response.items.isNotEmpty) {
        model = response.items.first;

        firstComparisonItem = await _api.items.getById(model.primaryId);
        secondComparisonItem = await _api.items.getById(model.secondaryId);
      }
    });
  }
}
