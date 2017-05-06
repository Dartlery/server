import 'extension_data.dart';

class ExtensionDataList {
  final List<ExtensionData> data;

  ExtensionDataList.from(List<ExtensionData> input) : data = input;

  ExtensionData get(String primaryId, String secondaryId) {
    for (ExtensionData eData in data) {
      if (eData.primaryId == primaryId && eData.secondaryId == secondaryId)
        return eData;
    }
    return null;
  }

  void addAll(List<ExtensionData> input) => data.addAll(input);

  bool contains(String primaryId, String secondaryId) =>
      get(primaryId, secondaryId) != null;
}
