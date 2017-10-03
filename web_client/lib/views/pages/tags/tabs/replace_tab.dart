import 'dart:async';
import 'dart:html' as html;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery/views/controls/common_controls.dart';
import 'package:dartlery_shared/global.dart';
import 'package:logging/logging.dart';
import 'package:tools/tools.dart';

@Component(
    selector: 'replace-tab',
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      CORE_DIRECTIVES,
      materialDirectives,
      commonControls
    ],
    template: '''
    <table>
    <tr>
    <td><tag-entry [singleTag]="false" [existingTags]="true" [(selectedTags)]="originalTags"></tag-entry></td>
    <td><tag-entry [singleTag]="false" [existingTags]="false" [(selectedTags)]="newTags"></tag-entry></td>
    <td><material-button (trigger)="performReplacement()">Replace</material-button></td>
    </tr></table>
    ''')
class ReplaceTab extends AApiView<ApiService> implements OnInit, OnDestroy {
  static final Logger _log = new Logger("ReplaceTab");

  List<Tag> originalTags = <Tag>[];
  List<Tag> newTags = <Tag>[];

  ReplaceTab(ApiService api, Router router,
      AuthenticationService authenticationService)
      : super(api, router, authenticationService);

  @override
  Logger get loggerImpl => _log;
  @override
  void ngOnDestroy() {}

  @override
  void ngOnInit() {}

  Future<Null> performReplacement() async {
    if (originalTags.isEmpty) return;
    await performApiCall(() async {
      final ReplaceTagsRequest request = new ReplaceTagsRequest();
      request.originalTags = originalTags;
      request.newTags = newTags;
      final CountResponse response = await api.tags.replace(request);
      html.window.alert("${response.count} items updated");
    });
  }
}
