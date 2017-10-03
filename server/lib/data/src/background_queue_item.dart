import 'package:server/data/data.dart';

class BackgroundQueueItem extends AIdData {
  dynamic data;
  DateTime added;
  String extensionId;
  int priority = 0;
}
