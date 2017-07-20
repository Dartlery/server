import 'dart:async';

import 'package:angular2/angular2.dart';
import 'package:angular2/router.dart';
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

@Component(
    selector: 'tags-page',
    directives: const [
      materialDirectives,
      commonControls,
      FORM_DIRECTIVES,
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

  StringSelectionOptions<String> categoryOptions =
      new StringSelectionOptions<String>([]);
  final SelectionModel<String> categorySelection =
      new SelectionModel<String>.withList();

  String tagQuery = "A";

  api.Tag model = new api.Tag();

  TagList tags = new TagList();
  StreamSubscription<PageAction> _pageActionSubscription;

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

  void onPageActionRequested(PageAction action) {
    try {
      switch (action) {
        case PageAction.refresh:
          this.refresh();
          break;
        default:
          throw new Exception(
              action.toString() + " not implemented for this page");
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
