import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:angular2/angular2.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular2/platform/common.dart';
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
import 'package:dartlery/views/controls/image_compare.dart';
import '../src/a_page.dart';
import 'package:dartlery_shared/tools.dart';

@Component(
    selector: 'deduplicate-page',
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      materialDirectives,
      ROUTER_DIRECTIVES,
      AuthStatusComponent,
      ErrorOutputComponent,
      commonControls,
      NgClass,
      ImageCompareComponent
    ],
    styleUrls: const <String>["../../shared.css", "deduplicate.css"],
    templateUrl: "deduplicate.html")
class DeduplicatePage extends APage implements OnInit, OnDestroy {
  static final Logger _log = new Logger("DeduplicatePage");

  ExtensionData model;
  Item firstComparisonItem = new Item();

  Item secondComparisonItem = new Item();

  List<ExtensionData> otherComparisons = <ExtensionData>[];

  int currentImage = 0;

  ApiService _api;
  Router _router;

  AuthenticationService _auth;

  Location _location;

  RouteParams _params;
  StreamSubscription<PageAction> _pageActionSubscription;
  String filterItemId;

  final NumberFormat f = new NumberFormat.decimalPattern();

  bool animatedComparison = true;


  DeduplicatePage(PageControlService pageControl, this._api, this._auth,
      this._router, this._params, this._location)
      : super(_auth, _router, pageControl) {
    pageControl.setPageTitle("Deduplicate");
    pageControl
        .setAvailablePageActions([PageAction.refresh, PageAction.compare]);
  }



  int get firstLength => int.parse(firstComparisonItem?.length ?? "0");
  int get secondLength=> int.parse(secondComparisonItem?.length ?? "0");

  int get lengthWinner {
    if (firstLength >
        secondLength) {
      return 0;
    } else if (firstLength <
        secondLength) {
      return 1;
    }
    return -1;

  }

  @override
  Logger get loggerImpl => _log;


  int get firstComparisonPixelCount =>
      (firstComparisonItem?.height ?? 0) * (firstComparisonItem?.width ?? 0);

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

  @override
  void ngOnDestroy() {
    _pageActionSubscription?.cancel();
  }

  @override
  void ngOnInit() {
    final String _id = _params.get(idRouteParameter);
    filterItemId = _id;
    _pageActionSubscription =
        pageControl.pageActionRequested.listen(onPageActionRequested);
    refresh();
  }

  void onPageActionRequested(PageAction action) {
    switch (action) {
      case PageAction.refresh:
        this.refresh();
        break;
      case PageAction.compare:
        animatedComparison = !animatedComparison;
        break;
      default:
        throw new Exception(
            action.toString() + " not implemented for this page");
    }
  }


  Future<Null> refresh() async {
    await performApiCall(() async {
      clear();
      PaginatedExtensionDataResponse response = await _api.extensionData
          .get("itemComparison", "similarItems",
              orderByValues: true, orderDescending: true, perPage: 1);
      if (response.items.isNotEmpty) {
        model = response.items.first;


        response = await _api.extensionData.getByPrimaryId("itemComparison", "similarItems", model.primaryId, bidirectional: true, orderByValues: true, orderDescending: true);
        otherComparisons = response.items;


        firstComparisonItem = await _api.items.getById(model.primaryId);
        secondComparisonItem = await _api.items.getById(model.secondaryId);
      }
    });
  }
}
