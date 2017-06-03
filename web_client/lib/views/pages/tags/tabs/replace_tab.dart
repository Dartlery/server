import 'package:dartlery_shared/tools.dart';
import 'dart:async';
import 'package:angular2/angular2.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery/data/data.dart';
import 'package:logging/logging.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/views/controls/common_controls.dart';
import 'package:dartlery/api/api.dart';
import 'package:angular2/router.dart';
import '../../../src/a_api_error_thing.dart';

@Component(
    selector: 'replace-tab',
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[materialDirectives, commonControls],
    template: '''
    <table>
    <tr>
    <td><tag-entry [singleTag]="true" [existingTags]="true" [(selectedTag)]="startTag"></tag-entry></td>
    <td><tag-entry [singleTag]="true" [existingTags]="true" [(selectedTag)]="endTag"></tag-entry></td>
    <td><material-button (trigger)="createRedirect()">Set</material-button></td>
    </tr></table>
    
    
    <div *ngIf="noItemsFound&&!processing" class="no-items">No Redirects Found</div>
    <table>
    <tr *ngFor="let t of redirects">
    <td>{{formatRedirectingTag(t)}}</td>
    <td><glyph icon="arrow_forward"></glyph></td>
    <td>{{formatTag(t.redirect)}}</td>
    <td><material-button icon><glyph icon="clear"></glyph></material-button></td>
    </tr>
    </table>
    ''')
class ReplaceTab extends AApiErrorThing implements OnInit, OnDestroy {
  static final Logger _log = new Logger("ReplaceTab");

  bool get noItemsFound => redirects.isEmpty;

  Tag startTag;
  Tag endTag;

  Future<Null> createRedirect() async {
    if(startTag==null||endTag==null)
      return;
    await performApiCall(() async {

      final RedirectingTag request = new RedirectingTag();
      request.id = startTag.id;
      request.category = startTag.category;

      request.redirect = endTag;

      await _api.tags.setRedirect(request);
      startTag = null;
      endTag = null;
      await refresh();
    });
  }

  final ApiService _api;

  ReplaceTab(this._api, this._pageControl, Router router,
      AuthenticationService authenticationService)
      : super(router, authenticationService);
  @override
  Logger get loggerImpl => _log;

  final PageControlService _pageControl;

  String formatTag(Tag t) => TagWrapper.formatTag(t);
  String formatRedirectingTag(RedirectingTag t) => TagWrapper.formatRedirectingTag(t);

  StreamSubscription<PageAction> _pageActionSubscription;

  final List<RedirectingTag> redirects = new List<RedirectingTag>();

  Future<Null> refresh() async {
    await performApiCall(() async {
      redirects.clear();
      redirects.addAll(await _api.tags.getRedirects());
    });
  }

  @override
  void ngOnInit() {
    refresh();
    _pageActionSubscription =
        _pageControl.pageActionRequested.listen(onPageActionRequested);
  }

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

  @override
  void ngOnDestroy() {
    _pageActionSubscription.cancel();
  }
}
