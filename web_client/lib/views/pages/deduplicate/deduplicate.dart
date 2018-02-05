import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_image_compare/image_compare_component.dart';
import 'package:angular_router/angular_router.dart';
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
import '../src/deduplicate_shared.dart';

@Component(
    selector: 'deduplicate-page',
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      CORE_DIRECTIVES,
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

  static const PageAction _removeAction =
      const PageAction("remove", "remove_circle", true);

  ApiService _api;
  Router _router;
  AuthenticationService _auth;
  Location _location;
  RouteParams _params;

  StreamSubscription<PageAction> _pageActionSubscription;

  List<ItemComparison> selectedItems = <ItemComparison>[];

  List<ItemComparison> comparisons = <ItemComparison>[];

  DeduplicatePage(PageControlService pageControl, this._api, this._auth,
      this._router, this._params, this._location)
      : super(_auth, _router, pageControl) {
    pageControl.setPageTitle("Deduplicate");
  }

  @override
  Logger get loggerImpl => _log;

  void clear() {
    comparisons.clear();
    selectedItems.clear();
  }

  Future<Null> clearSelected(List<ItemComparison> items) async {
    pageControl.setIndeterminateProgress();
    await performApiCall(() async {
      int i = 1;
      int total = 0;
      items.forEach((ItemComparison ic) => total += ic.comparisons.length);

      pageControl.setProgress(0, max: total);
      while (items.isNotEmpty) {
        final ItemComparison comparison = items[0];
        while (comparison.comparisons.isNotEmpty) {
          final ExtensionData data = comparison.comparisons.first;
          await _api.extensionData.delete("itemComparison", "similarItems",
              data.primaryId, data.secondaryId);
          comparison.comparisons.removeAt(0);
          pageControl.setProgress(i, max: total + 1);
          i++;
        }
        items.removeAt(0);
      }
      pageControl.setProgress(total + 1, max: total + 1);

      await refresh();
    });
  }

  Future<Null> clearSimilarity(ItemComparison data) => clearSelected([data]);

  Future<Null> deleteAll(List<ItemComparison> items) async {
    pageControl.setIndeterminateProgress();

    await performApiCall(() async {
      int i = 1;
      int total = 0;
      items.forEach((ItemComparison ic) => total += ic.comparisons.length);

      pageControl.setProgress(0, max: total);
      while (items.isNotEmpty) {
        final ItemComparison comparison = items[0];
        final ExtensionData primaryData = comparison.primary;
        while (comparison.comparisons.isNotEmpty) {
          final ExtensionData data = comparison.comparisons.first;
          final String toDelete =
              DeduplicateShared.getOtherImageId(primaryData.primaryId, data);
          if (isNotNullOrWhitespace(toDelete)) {
            await _api.items.delete(toDelete);
          }
          comparison.comparisons.removeAt(0);
          pageControl.setProgress(i, max: total + 1);
          i++;
        }
        await _api.items.delete(primaryData.primaryId);
        items.removeAt(0);
        pageControl.setProgress(i, max: total + 1);
        i++;
      }
      pageControl.setProgress(total + 1, max: total + 1);

      await refresh();
    });
  }

  void itemSelectChanged(bool checked, ItemComparison ic) {
    if (checked) {
      if (!this.selectedItems.contains(ic)) this.selectedItems.add(ic);
    } else {
      if (this.selectedItems.contains(ic)) this.selectedItems.remove(ic);
    }
    setPageActions();
  }

  @override
  void ngOnDestroy() {
    _pageActionSubscription?.cancel();
  }

  @override
  void ngOnInit() {
    setPageActions();

    _pageActionSubscription =
        pageControl.pageActionRequested.listen(onPageActionRequested);
    refresh();
  }

  void onPageActionRequested(PageAction action) {
    switch (action) {
      case PageAction.refresh:
        this.refresh();
        break;
      case _removeAction:
        this.clearSelected(this.selectedItems);
        break;
      case PageAction.delete:
        this.deleteAll(this.selectedItems);
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
        clear();
        response = await _api.extensionData.get(
            "itemComparison", "similarItems",
            orderDescending: false, perPage: 30);
        if (response.items.isNotEmpty) {
          for (ExtensionData ed in response.items) {
            if(this.comparisons.where((ItemComparison ic) =>
              ic.containsId(ed.primaryId)
            ).isNotEmpty) continue;

            response = await _api.extensionData.getByPrimaryId(
                "itemComparison", "similarItems", ed.primaryId,
                bidirectional: true,
                orderByValues: true,
                orderDescending: true,
                perPage: 100);

            this.comparisons.add(new ItemComparison(ed, response.items));
          }
        }
      } on DetailedApiRequestError catch (e) {
        if (e.status != 404) throw e;
      }
    }, after: () async {
      pageControl.clearProgress();
    });
  }

  setPageActions() {
    final List<PageAction> actions = <PageAction>[];

    if (selectedItems.length > 0) {
      actions.add(PageAction.delete);
      actions.add(_removeAction);
    }
    actions.add(PageAction.refresh);

    pageControl.setAvailablePageActions(actions);
  }
}

class ItemComparison {
  List<ExtensionData> comparisons = <ExtensionData>[];

  final ExtensionData primary;

  ItemComparison(this.primary, this.comparisons);
  String get primaryId => this.primary.primaryId;

  bool containsId(String id) {
    if(this.primaryId==id)
      return true;

    for(ExtensionData ed in comparisons) {
      if(ed.secondaryId==id||ed.primaryId==id)
        return true;
    }
  }

  Iterable<String> get secondaryIds =>
      this.comparisons.map((ExtensionData ed) =>
          DeduplicateShared.getOtherImageId(this.primaryId, ed));
}
