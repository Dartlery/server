import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/services/services.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:logging/logging.dart';
import 'package:lib_angular/views/views.dart';

@Component(
    selector: 'import-page',
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      CORE_DIRECTIVES,
      formDirectives,
      materialDirectives,
      ROUTER_DIRECTIVES,
      libComponents
    ],
    styleUrls: const <String>["package:lib_angular/shared.css"],
    styles: const <String>["table.importResults { user-select: text; } "],
    templateUrl: "import_page.html")
class ImportPage extends APage<ApiService> implements OnInit, OnDestroy {
  static final Logger _log = new Logger("ImportPage");

  final AuthenticationService _auth;

  final SelectionOptions<ImportBatch> batchOptions =
      new SelectionOptions<ImportBatch>([]);

  final SelectionModel<ImportBatch> batchSelection =
      new SelectionModel<ImportBatch>.withList();

  void onSelectionChanged(dynamic test) {
    refresh();
  }

  String get batchSelectedText => batchSelection.selectedValues.isEmpty
      ? "Select Batch"
      : batchRenderer(batchSelection.selectedValues.first);

  final ItemRenderer<ImportBatch> batchRenderer =
      (ImportBatch item) => item.timestamp.toString();

  final ImportPathRequest request = new ImportPathRequest()
    ..interpretFileNames = true
    ..mergeExisting = true;

  final List<ImportResult> results = <ImportResult>[];

  final List<ImportBatch> batches = <ImportBatch>[];

  ImportBatch get batch => batchSelection.selectedValues.isEmpty
      ? null
      : batchSelection.selectedValues.first;

  ImportPage(
      PageControlService pageControl, ApiService api, this._auth, Router router)
      : super(api, _auth, router, pageControl) {
    pageControl.setPageTitle("Import");
    pageControl.setAvailablePageActions([PageAction.refresh]);
    batchSelection.selectionChanges.listen(onSelectionChanged);
  }

  @override
  Logger get loggerImpl => _log;

  @override
  void ngOnInit() {
    _pageActionSubscription =
        pageControl.pageActionRequested.listen(onPageActionRequested);
    refresh();
  }

  StreamSubscription<PageAction> _pageActionSubscription;

  @override
  void ngOnDestroy() {
    _pageActionSubscription.cancel();
  }

  void onPageActionRequested(PageAction action) {
    switch (action) {
      case PageAction.refresh:
        this.refresh();
        break;
      default:
        throw new Exception(
            action.toString() + " not implemented for this page");
    }
  }

  bool refreshing = false;
  Future<Null> refresh() async {
    try {
      if (refreshing) return;
      refreshing = true;
      pageControl.setIndeterminateProgress();
      await performApiCall(() async {
        batches.clear();
        results.clear();
        batchOptions.optionGroups.clear();
        batches.addAll(await api.import.getImportBatches());

        final OptionGroup<ImportBatch> batchGroup =
            new OptionGroup<ImportBatch>(batches);
        batchOptions.optionGroups.add(batchGroup);

        if (batch != null) {
          results
              .addAll((await api.import.getImportBatchResults(batch.id)).items);
        }
      }, after: () async {
        pageControl.clearProgress();
      });
    } finally {
      refreshing = false;
    }
  }

  Future<Null> clearSuccessResults() async {
    if (batch == null) return;
    await performApiCall(() async {
      await api.import.clearResults(batch.id);
    });
    await refresh();
  }

  Future<Null> clearAllResults() async {
    if (batch == null) return;
    await performApiCall(() async {
      await api.import.clearResults(batch.id, everything: true);
    });
    batchSelection.clear();
    await refresh();
  }

  Future<Null> beginImport() async {
    await performApiCall(() async {
      final StringResponse response = await api.import.importFromPath(request);
      final String id = response.data;
      await refresh();
      batches.forEach((ImportBatch ib) {
        if (ib.id == id) {
          batchSelection.select(ib);
        }
      });
    });
  }
}
