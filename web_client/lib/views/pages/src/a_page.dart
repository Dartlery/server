import 'dart:html' as html;
import 'package:dartlery/client.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:angular_router/angular_router.dart';
import 'package:dartlery/data/data.dart';
import '../../src/a_api_error_thing.dart';
import 'package:dartlery/api/api.dart';
import 'dart:math';
import 'package:dartlery/angular_page_control/angular_page_control.dart';
import '../../src/a_view.dart';

abstract class APage extends AApiErrorThing with AView {
  final PageControlService pageControl;

  APage(AuthenticationService auth, Router router, this.pageControl)
      : super(router, auth);

  bool popupUnhandledErrors = true;
  @override
  set errorMessage(String message) {
    super.errorMessage = message;
    if (popupUnhandledErrors && isNotNullOrWhitespace(message))
      pageControl.sendMessage(new PageMessage("Error", message));
  }



  String getViewWidthString([int offset = 0]) {
    return "${html.window.innerWidth+offset}px";
  }

  String getViewHeightString([int offset = 0]) {
    // The top toolbar is currently permanent, so this height calculation automatically subtracts its height
    return "${html.window.innerHeight+offset-64}px";
  }

}
