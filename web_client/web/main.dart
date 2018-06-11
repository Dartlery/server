import 'package:angular/angular.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';
import "package:intl/intl_browser.dart";

import 'package:dartlery/views/main_app/main_app.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/views/main_app/main_app.template.dart' as ng;

Future<Null> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(new LogPrintHandler());
  await findSystemLocale();

  runApp(ng.MainAppNgFactory);
}
