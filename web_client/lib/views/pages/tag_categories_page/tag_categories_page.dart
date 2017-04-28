import 'dart:async';

import 'package:angular2/angular2.dart';
import 'package:angular2/router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/api/api.dart' as api;
import 'package:dartlery/services/services.dart';
import 'package:dartlery/views/controls/common_controls.dart';
import 'package:logging/logging.dart';
import 'package:dartlery/data/data.dart';
import '../src/a_maintenance_page.dart';

@Component(
    selector: 'collections-page',
    directives: const [materialDirectives, commonControls],
    providers: const [materialProviders],
    styleUrls: const ["../../shared.css", "tag_categories_page.css"],
    templateUrl: 'tag_categories_page.html')
class TagCategoriesPage extends AMaintenancePage<api.TagCategory> {
  static final Logger _log = new Logger("TagCategoriesPage");

  TagCategoriesPage(PageControlService pageControl, ApiService api,
      AuthenticationService auth, Router router)
      : super("Collection", pageControl, api, auth, router) {
    pageControl.setPageTitle("Collections");
  }

  @override
  dynamic get itemApi => this.api.tagCategories;

  @override
  Logger get loggerImpl => _log;

  @override
  api.TagCategory createBlank() {
    final api.TagCategory model = new api.TagCategory();
    return model;
  }

  @override
  Future<List<String>> getItems() async {
    return await this.api.tagCategories.getAllIds();
  }
}