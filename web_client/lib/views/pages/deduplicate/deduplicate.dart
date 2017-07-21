import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';

import 'package:angular2/angular2.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular2/platform/common.dart';
import 'package:angular2/router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_image_compare/image_compare_component.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/client.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/routes.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery/views/controls/auth_status_component.dart';
import 'package:dartlery/views/controls/common_controls.dart';
import 'package:dartlery/views/controls/error_output.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
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
      ImageCompareComponent,
      commonControls,
      NgClass,
    ],
    styleUrls: const <String>["../../shared.css", "deduplicate.css"],
    templateUrl: "deduplicate.html")
class DeduplicatePage extends APage implements OnInit, OnDestroy {
  static final Logger _log = new Logger("DeduplicatePage");

  static const PageAction _animatePageAction =
      const PageAction("animate", "av_timer");

  String currentItemId;
  ExtensionData model;

  Item firstComparisonItem = new Item();

  Item secondComparisonItem = new Item();

  List<ExtensionData> otherComparisons = <ExtensionData>[];

  int currentImage = 0;

  bool splitComparison = false;
  ApiService _api;

  Router _router;

  AuthenticationService _auth;

  Location _location;
  RouteParams _params;
  StreamSubscription<PageAction> _pageActionSubscription;

  String filterItemId;

  final NumberFormat f = new NumberFormat.decimalPattern();

  bool animatedComparison = true;

  // TODO: Learn how to use this animate class for this: https://github.com/dart-lang/angular_components/blob/master/lib/src/components/material_progress/material_progress.dart

  TagList differentTags = new TagList();

  DeduplicatePage(PageControlService pageControl, this._api, this._auth,
      this._router, this._params, this._location)
      : super(_auth, _router, pageControl) {
    pageControl.setPageTitle("Deduplicate");
    pageControl.setAvailablePageActions(
        [PageAction.refresh, PageAction.compare, _animatePageAction]);
  }
  int get firstComparisonPixelCount =>
      (firstComparisonItem?.height ?? 0) * (firstComparisonItem?.width ?? 0);

  int get firstLength => int.parse(firstComparisonItem?.length ?? "0");

  int get lengthWinner {
    if (firstLength > secondLength) {
      return 0;
    } else if (firstLength < secondLength) {
      return 1;
    }
    return -1;
  }

  int totalItems = 0;

  @override
  Logger get loggerImpl => _log;

  int get secondComparisonPixelCount =>
      (secondComparisonItem?.height ?? 0) * (secondComparisonItem?.width ?? 0);

  int get secondLength => int.parse(secondComparisonItem?.length ?? "0");

  int get sizeWinner {
    if (firstComparisonPixelCount > secondComparisonPixelCount) {
      return 0;
    } else if (firstComparisonPixelCount < secondComparisonPixelCount) {
      return 1;
    }
    return -1;
  }

  void clear() {
    currentItemId = "";
    model = null;
    firstComparisonItem = new Item();
    secondComparisonItem = new Item();
    otherComparisons.clear();
    differentTags.clear();
  }

  Future<Null> clearAll() async {
    pageControl.setIndeterminateProgress();
    await performApiCall(() async {
      int i = 1;
      final int total = otherComparisons.length;
      pageControl.setProgress(0, max: total);
      while (otherComparisons.isNotEmpty) {
        final ExtensionData data = otherComparisons[0];
        await _api.extensionData.delete(
            "itemComparison", "similarItems", data.primaryId, data.secondaryId);
        otherComparisons.removeAt(0);
        pageControl.setProgress(i, max: total);
        i++;
      }
      await refresh();
    });
  }

  Future<Null> clearSimilarity(ExtensionData data) async {
    pageControl.setIndeterminateProgress();
    await performApiCall(() async {
      await _api.extensionData.delete(
          "itemComparison", "similarItems", data.primaryId, data.secondaryId);
    });
    await refresh();
  }

  Future<Null> deleteItem(String id) async {
    pageControl.setIndeterminateProgress();
    await performApiCall(() async {
      await _api.items.delete(id);

      if (id == currentItemId) currentItemId == "";
    });
    await refresh();
  }

  String getOtherImageId(ExtensionData data) {
    if (isNullOrWhitespace(currentItemId)) return "";
    if (data.primaryId == currentItemId) {
      return data.secondaryId;
    } else {
      return data.primaryId;
    }
  }

  Future<Null> mergeItems(String sourceId, String targetId,
      {bool refresh: true}) async {
    pageControl.setIndeterminateProgress();
    await performApiCall(() async {
      final IdRequest request = new IdRequest();
      request.id = sourceId;
      await _api.items.mergeItems(request, targetId);
      if (sourceId == currentItemId) currentItemId == "";
    }, after: () async {
      pageControl.clearProgress();
    });
    if (refresh) await this.refresh();
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
        splitComparison = !splitComparison;
        break;
      case _animatePageAction:
        animatedComparison = !animatedComparison;
        break;
      default:
        throw new Exception(
            action.toString() + " not implemented for this page");
    }
  }

  Future<Null> refresh() async {
    pageControl.setIndeterminateProgress();
    PaginatedExtensionDataResponse response;
    await performApiCall(() async {
      try {
        if (isNotNullOrWhitespace(currentItemId)) {
          final String currentItemId = this.currentItemId;
          response = await _api.extensionData.getByPrimaryId(
              "itemComparison", "similarItems", currentItemId,
              bidirectional: true,
              orderByValues: true,
              orderDescending: true,
              perPage: 100);
          clear();
          if (response.items.isNotEmpty) {
            this.currentItemId = currentItemId;
            otherComparisons = response.items;
            await selectComparison(response.items.first);
            return;
          }
        }
      } on DetailedApiRequestError catch (e, st) {
        if (e.status != 404) throw e;
      }

      try {
        clear();
        response = await _api.extensionData.get(
            "itemComparison", "similarItems",
            orderDescending: true, perPage: 1);
        if (response.items.isNotEmpty) {
          totalItems = response.totalCount;
          currentItemId = response.items.first.primaryId;
          response = await _api.extensionData.getByPrimaryId(
              "itemComparison", "similarItems", currentItemId,
              bidirectional: true,
              orderByValues: true,
              orderDescending: true,
              perPage: 100);
          otherComparisons = response.items;
          await selectComparison(response.items.first);
        }
      } on DetailedApiRequestError catch (e, st) {
        if (e.status != 404) throw e;
      }
    }, after: () async {
      pageControl.clearProgress();
    });
  }

  Future<Null> selectComparison(ExtensionData ed) async {
    pageControl.setIndeterminateProgress();
    await performApiCall(() async {
      model = ed;

      if (isNotNullOrWhitespace(currentItemId)) {
        firstComparisonItem = await _api.items.getById(currentItemId);
        secondComparisonItem = await _api.items.getById(getOtherImageId(ed));
      } else {
        firstComparisonItem = await _api.items.getById(model.primaryId);
        secondComparisonItem = await _api.items.getById(model.secondaryId);
      }
      final Diff<TagWrapper> tagDiff = new Diff<TagWrapper>(
          firstComparisonItem.tags.map((Tag t) => new TagWrapper.fromTag(t)),
          secondComparisonItem.tags.map((Tag t) => new TagWrapper.fromTag(t)));
      differentTags.clear();
      differentTags.addAll(tagDiff.different);
    }, after: () async {
      pageControl.clearProgress();
    });
  }
}
