class ImportBatch {
  DateTime batchTimestamp;
  String source;
  Map<String, int> importCounts = <String,int>{};

  ImportBatch();

  void addImportResult(String result) {
    if(!importCounts.containsKey(result))
      importCounts[result] = 0;

    importCounts[result]++;
  }
}
