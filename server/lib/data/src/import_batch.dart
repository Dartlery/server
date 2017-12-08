import 'package:tools/tools.dart';
import 'package:server/data/data.dart';
import 'package:rpc/rpc.dart';
import 'package:server/data_sources/data_sources.dart';

@ApiMessage(includeSuper: true)
class ImportBatch extends AIdData {
  static const String timestampField = "timestamp";
  static const String importCountsField = "importCounts";
  static const String sourceField = "source";
  static const String finishedField = "finished";

  static const String importBatchesTimestampIndexName = "ImportBatchesTimestamp";
  static const String importBatchesIdIndexName = "ImportBatchesInverseIndex";


  @DbIndex(importBatchesTimestampIndexName, unique: true, ascending: false)
  DateTime timestamp;

  String source;
  Map<String, int> importCounts = <String, int>{};
  bool finished = false;

  ImportBatch() : super.withValues(generateUuid());

  void addImportResult(String result) {
    if (!importCounts.containsKey(result)) importCounts[result] = 0;

    importCounts[result]++;
  }
}
