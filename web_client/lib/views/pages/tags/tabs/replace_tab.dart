import 'package:dartlery_shared/tools.dart';
import 'dart:html' as html;
import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery/data/data.dart';
import 'package:logging/logging.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/views/controls/common_controls.dart';
import 'package:dartlery/api/api.dart';
import 'package:angular_router/angular_router.dart';
import '../../../src/a_api_error_thing.dart';

@Component(
    selector: 'replace-tab',
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      coreDirectives,
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
class ReplaceTab extends AApiErrorThing implements OnInit, OnDestroy {
  static final Logger _log = new Logger("ReplaceTab");

  List<Tag> originalTags = <Tag>[];
  List<Tag> newTags = <Tag>[];

  Future<Null> performReplacement() async {
    if (originalTags.isEmpty) return;
    await performApiCall(() async {
      final ReplaceTagsRequest request = new ReplaceTagsRequest();
      request.originalTags = originalTags;
      request.newTags = newTags;
      final CountResponse response = await _api.tags.replace(request);
      html.window.alert("${response.count} items updated");
    });
  }

  final ApiService _api;

  ReplaceTab(
      this._api, Router router, AuthenticationService authenticationService)
      : super(router, authenticationService);
  @override
  Logger get loggerImpl => _log;

  @override
  void ngOnInit() {}

  @override
  void ngOnDestroy() {}
}
