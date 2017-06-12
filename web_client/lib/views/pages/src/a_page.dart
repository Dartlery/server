import 'dart:html' as html;
import 'package:dartlery/client.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:angular2/router.dart';
import 'package:dartlery/data/data.dart';
import '../../src/a_api_error_thing.dart';
import 'package:dartlery/api/api.dart';
import 'dart:math';

abstract class APage extends AApiErrorThing {
  final PageControlService pageControl;

  APage(AuthenticationService auth, Router router, this.pageControl)
      : super(router, auth);

  bool popupUnhandledErrors = true;
  @override
  set errorMessage(String message) {
    super.errorMessage = message;
    if (popupUnhandledErrors && isNotNullOrWhitespace(message))
      pageControl.sendMessage("Error", message);
  }

  String formatTag(Tag t) => TagWrapper.formatTag(t);

  void cancelEvent(html.Event e) {
    e.stopPropagation();
    e.preventDefault();
    e.stopImmediatePropagation();
  }

  String getViewWidthString([int offset = 0]) {
    return "${html.window.innerWidth+offset}px";
  }

  String getViewHeightString([int offset = 0]) {
    // The top toolbar is currently permanent, so this height calculation automatically subtracts its height
    return "${html.window.innerHeight+offset-64}px";
  }

  String getFullFileUrl(Item item) {
    if (item == null || isNullOrWhitespace(item.id)) return "";
    if (item.fullFileAvailable)
      return getImageUrl(item.id, ItemFileType.full);
    else
      return getImageUrl(item.id, ItemFileType.original);
  }

  String getOriginalFileUrl(String value) {
    if (isNullOrWhitespace(value)) return "";
    final String output = getImageUrl(value, ItemFileType.original);
    return output;
  }

  String getThumbnailFileUrl(String value) {
    if (isNullOrWhitespace(value)) return "";
    final String output = getImageUrl(value, ItemFileType.thumbnail);
    return output;
  }
}
