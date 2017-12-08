import 'package:server/data_sources/data_sources.dart';

class ImportResult {
  static const String importResultsTimestampIndexName = "ImportResultsTimestamp";
  static const String importResultsResultIndexName = "ImportResultsResult";
  static const String importResultsBatchIndexName = "ImportResultsBatch";

  @DbIndex(importResultsBatchIndexName)
  String batchId;

  String itemId;
  String fileName;

  @DbIndex(importResultsResultIndexName)
  String result;
  bool thumbnailCreated = false;
  String error;

  @DbIndex(importResultsTimestampIndexName, ascending: false)
  DateTime timestamp;

  ImportResult();
}
