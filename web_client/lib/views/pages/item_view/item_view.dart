import 'package:dartlery_shared/tools.dart';
import 'package:dartlery_shared/global.dart';
import 'dart:async';
import 'package:dartlery/client.dart';
import 'package:angular2/angular2.dart';
import 'package:angular2/platform/common.dart';

import 'package:angular2/router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/routes.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery/views/controls/auth_status_component.dart';
import 'package:dartlery/views/controls/error_output.dart';
import 'package:logging/logging.dart';
import '../src/a_page.dart';
import 'package:dartlery/views/controls/common_controls.dart';

@Component(
    selector: 'item-view',
    providers: const <dynamic>[materialProviders],
    directives: const <dynamic>[
      materialDirectives,
      ROUTER_DIRECTIVES,
      AuthStatusComponent,
      ErrorOutputComponent,
      commonControls
    ],
    styleUrls: const <String>["../../shared.css"],
    templateUrl: "item_view.html")
class ItemViewPage extends APage implements OnInit {
  static final Logger _log = new Logger("ItemViewPage");

  NgForm form;

  Item model = new Item();

  static const List<String> imageMimeTypes = const <String>[
    "image/jpeg",
    "image/gif",
    "image/png",
  ];

  static const List<String> videoMimeTypes = const <String>[
    'video/webm',
    'video/mp4',
    //'application/x-shockwave-flash',
    'video/x-flv',
    'video/quicktime',
    'video/avi',
    'video/x-ms-asf',
    'video/mpeg'
  ];

  bool get isImage {
    return imageMimeTypes.contains(model?.mime);
  }

  bool get isVideo {
    return videoMimeTypes.contains(model?.mime);
  }


  PageControlService _pageControl;
  ApiService _api;
  Router _router;
  AuthenticationService _auth;
  Location _location;
  RouteParams _params;

  String itemId;

  StreamSubscription<PageActions> _pageActionSubscription;


  ItemViewPage(this._pageControl, this._api, this._auth, this._router, this._params, this._location)
      : super(_auth, _router) {
    _pageControl.setPageTitle("Setup");
    _pageControl.setAvailablePageActions([PageActions.Refresh, PageActions.Delete]);

  }

  String getOriginalFileUrl(String value) {
    if(StringTools.isNullOrWhitespace(value))
      return "";
    final String output = getImageUrl(value, ImageType.original);
    return output;
  }

  @override
  Logger get loggerImpl => _log;

  @override
  void ngOnInit() {
    final String _id = _params.get(idRouteParameter);
    if(StringTools.isNullOrWhitespace(_id))
      throw new Exception("Empty ID passed");
    itemId = _id;
    _pageActionSubscription =
        _pageControl.pageActionRequested.listen(onPageActionRequested);
    refresh();
  }


  @override
  void ngOnDestroy() {
    _pageActionSubscription.cancel();
  }


  void onPageActionRequested(PageActions action) {
    switch (action) {
      case PageActions.Refresh:
        this.refresh();
        break;
      case PageActions.Delete:
        delete();
        break;
      default:
        throw new Exception(
            action.toString() + " not implemented for this page");
    }
  }

  Future<Null> delete() async {
    await performApiCall(() async {
        model = await _api.items.delete(itemId);
        _location.back();
    });
  }

  Future<Null> refresh() async {
    await performApiCall(() async {
        model = await _api.items.getById(itemId);
    });
  }

  Future<Null> onSubmit() async {
    await performApiCall(() async {
        await refresh();
    }, form:  form);
  }

  void clear() {
  }
}
