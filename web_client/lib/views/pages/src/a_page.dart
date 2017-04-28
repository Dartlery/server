import 'dart:async';
import 'dart:html';

import 'package:angular2/angular2.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:angular2/router.dart';
import 'package:dartlery/routes.dart';
import '../../src/a_api_error_thing.dart';
import 'package:meta/meta.dart';

abstract class APage extends AApiErrorThing {



  APage(AuthenticationService auth, Router router): super(router, auth);
}
