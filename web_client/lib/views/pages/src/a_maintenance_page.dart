import 'dart:async';

import 'package:angular2/angular2.dart';
import 'package:angular2/router.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:meta/meta.dart';

import 'a_page.dart';

abstract class AMaintenancePage<T> extends APage implements OnInit, OnDestroy {
  List<String> items = <String>[];

  String selectedId;

  dynamic model;

  StreamSubscription<PageActions> _pageActionSubscription;

  final PageControlService _pageControl;

  @protected
  final ApiService api;

  @ViewChild("editForm")
  NgForm form;

  bool showDeleteConfirmation = false;

  final String dataType;


  AMaintenancePage(this.dataType, this._pageControl, this.api,
      AuthenticationService _auth, Router router)
      : super(_auth, router) {
    _pageControl.setAvailablePageActions(
        <PageActions>[PageActions.Refresh, PageActions.Add]);
    _pageActionSubscription =
        _pageControl.pageActionRequested.listen(onPageActionRequested);
    this.model = createBlank();
  }

  bool get isNewItem => StringTools.isNullOrWhitespace(model.id);

  dynamic get itemApi;

  bool get noItemsFound => items.isEmpty;

  void authorizationChanged(bool value) {
    this.userAuthorized = value;
    if (value) {
      refresh();
    } else {
      clear();
    }
  }

  void cancelEdit() {
    reset();
    for (int i = 0; i < items.length; i++) {
      if (StringTools.isNullOrWhitespace(items[i])) {
        items.removeAt(i);
        i--;
      }
    }
  }

  void clear() {
    reset();
    items.clear();
  }

  T createBlank();

  Future<Null> deleteClicked() async {
    showDeleteConfirmation = true;
  }

  Future<Null> deleteConfirmClicked() async {
    await performApiCall(() async {
      await itemApi.delete(selectedId);
      await refresh();
    });
  }

  @override
  void ngOnDestroy() {
    _pageActionSubscription.cancel();
    _pageControl.reset();
  }

  @override
  void ngOnInit() {
    //refresh();
  }

  void onPageActionRequested(PageActions action) {
    try {
      switch (action) {
        case PageActions.Refresh:
          this.refresh();
          break;
        case PageActions.Add:
          cancelEdit();
          final String id = "";
          items.insert(0, id);
          break;
        default:
          throw new Exception(
              action.toString() + " not implemented for this page");
      }
    } catch (e, st) {
      handleException(e, st);
    }
  }

  Future<Null> onSubmit() async {
    await performApiCall(() async {
      if (isNewItem) {
        await itemApi.create(model);
      } else {
        await itemApi.update(model, selectedId);
      }
      await this.refresh();
    }, form: form);
  }

  Future<Null> refresh() async {
    await performApiCall(() async {

      final List<String> data = await getItems();
      items.clear();
      items.addAll(data);
      await refreshInternal();
    });
  }


  Future<List<String>> getItems();

  Future<Null> refreshInternal() async {}

  void reset() {
    model = createBlank();
    selectedId = null;
    showDeleteConfirmation = false;
    errorMessage = "";
  }

  Future<Null> selectItem(String id) async {
    await performApiCall(() async {
      reset();
      if (StringTools.isNotNullOrWhitespace(id))
        model = await itemApi.getById(id);
      selectedId = id;
      await selectItemInternal(id);
    });
  }

  Future<Null> selectItemInternal(String id) async {}

}
