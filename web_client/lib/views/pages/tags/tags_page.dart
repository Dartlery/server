import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/api/api.dart' as api;
import 'package:dartlery/data/data.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery/views/controls/common_controls.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import 'tabs/redirects_tab.dart';
import 'tabs/replace_tab.dart';
import '../src/a_page.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:dartlery/angular_page_control/angular_page_control.dart';

@Component(
    selector: 'tags-page',
    directives: const [
      CORE_DIRECTIVES,
      materialDirectives,
      commonControls,
      formDirectives,
      RedirectsTab,
      ReplaceTab,
      ROUTER_DIRECTIVES
    ],
    providers: const [materialProviders],
    styleUrls: const ["../../shared.css", "tags_page.css"],
    templateUrl: 'tags_page.html')
class TagsPage extends APage implements OnDestroy {
  static final Logger _log = new Logger("TagsPage");

  final ApiService _api;

  api.Tag selectedTag;

  bool showRedirects = false;

  StringSelectionOptions<String> categoryOptions =
      new StringSelectionOptions<String>([]);
  final SelectionModel<String> categorySelection =
      new SelectionModel<String>.withList();

  String tagQuery = "A";

  api.Tag model = new api.Tag();

  TagList tags = new TagList();
  StreamSubscription<PageActionEventArgs> _pageActionSubscription;

  @ViewChild("editForm")
  NgForm form;

  TagsPage(PageControlService pageControl, this._api,
      AuthenticationService auth, Router router)
      : super(auth, router, pageControl) {
    pageControl.setPageTitle("Tags");
    pageControl.setAvailablePageActions(<PageAction>[PageAction.refresh]);
    _pageActionSubscription =
        pageControl.pageActionRequested.listen(onPageActionRequested);
  }

  @override
  void ngOnDestroy() {
    _pageActionSubscription.cancel();
    pageControl.reset();
  }

  @override
  Logger get loggerImpl => _log;

  bool get noItemsFound => tags.isEmpty;

  void onPageActionRequested(PageActionEventArgs e) {
    try {
      switch (e.action) {
        case PageAction.refresh:
          this.refresh();
          break;
        default:
          throw new Exception(
              e.action.toString() + " not implemented for this page");
      }
    } catch (e, st) {
      handleException(e, st);
    }
  }

  void authorizationChanged(bool value) {
    this.userAuthorized = value;
    if (value) {
      refresh();
    } else {
      clear();
    }
  }

  void cancelEdit() {}

  void clear() {
    tags.clear();
    reset();
  }

  String get categoryButtonText => categorySelection.selectedValues.length > 0
      ? categorySelection.selectedValues.first
      : 'Category...';

  Future<Null> onSubmit() async {
    pageControl.setIndeterminateProgress();
    await performApiCall(() async {
      if (categorySelection.selectedValues.length > 0)
        model.category = categorySelection.selectedValues.first;
      else
        model.category = "";

//      if(StringTools.isNullOrWhitespace(selectedTag.category))
//        await _api.tags.updateWithoutCategory(model, selectedTag.id);
//      else
//        await _api.tags.update(model, selectedTag.id, selectedTag.category);
    }, form: form);
    await this.refresh();
  }

  Future<Null> recountTags() async {
    pageControl.setIndeterminateProgress();
    await performApiCall(() async {
      await _api.tags.resetTagInfo();
    });
    await refresh();
  }

  Future<Null> deleteSelected() async {
    final Iterable<TagWrapper> selected =
        tags.where((TagWrapper tw) => tw.selected).toList();
    pageControl.setProgress(0, max: selected.length);
    int i = 1;
    await performApiCall(() async {
      for (TagWrapper tag in selected) {
        if (tag.hasCategory) {
          await _api.tags.delete(tag.id, tag.category);
        } else {
          await _api.tags.deleteWithoutCategory(tag.id);
        }
        tags.remove(tag);
        pageControl.setProgress(i, max: selected.length);
        i++;
      }
    });
    await refresh();
  }

  Future<Null> deleteTag(TagWrapper tag) async {
    pageControl.setIndeterminateProgress();
    await performApiCall(() async {
      if (tag.hasCategory) {
        await _api.tags.delete(tag.id, tag.category);
      } else {
        await _api.tags.deleteWithoutCategory(tag.id);
      }
    });
    await refresh();
  }

  Future<Null> refresh() async {
    pageControl.setIndeterminateProgress();
    await performApiCall(() async {
      final List<String> categories = await _api.tagCategories.getAllIds();
      categories.insert(0, "");
      categoryOptions = new StringSelectionOptions<String>(categories);

      tags.clear();
      api.PaginatedTagResponse data;
      if (isNullOrWhitespace(tagQuery)) {
        data = await _api.tags.getAllTagInfo();
      } else {
        if (!showRedirects)
          data = await _api.tags.search(tagQuery, redirects: false);
        else
          data = await _api.tags.search(tagQuery);
      }
      tags.addTagInfos(data.items);
    }, after: () async {
      pageControl.clearProgress();
    });
  }

  void reset() {
    selectedTag = null;
    model = new api.Tag();
    errorMessage = "";
  }

  void selectTag(TagWrapper t) {
    selectedTag = t.tag;
    model = new api.Tag();
    model.id = t.tag.id;
    model.category = t.tag.category;
    if (isNullOrWhitespace(t.tag.category)) {
      categorySelection.clear();
    } else {
      categorySelection.select(t.tag.category);
    }
  }
}
