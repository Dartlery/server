import 'package:angular2/platform/browser.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';
import "package:intl/intl_browser.dart";

import 'package:dartlery/views/main_app/main_app.dart';
import 'dart:async';
import 'package:logging/logging.dart';

Future<Null> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(new LogPrintHandler());
  await findSystemLocale();

  await bootstrap(MainApp);
}
