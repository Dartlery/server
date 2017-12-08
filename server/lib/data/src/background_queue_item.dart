import 'package:server/data_sources/data_sources.dart';
import 'package:server/data/data.dart';

class BackgroundQueueItem extends AIdData {
  static const String dataField = 'data';
  static const String addedField = "added";
  static const String extensionIdField = "extensionId";
  static const String priorityField = "priority";
  static const int defaultPriority = 50;

  static const String priorityIndexName = "Priority";

  dynamic data;

  @DbIndex(priorityIndexName, order: 1)
  DateTime added;

  String extensionId;

  @DbIndex(priorityIndexName, order: 0)
  int priority = defaultPriority;
}
