import 'package:dartlery/api/api.dart';
import 'package:dartlery_shared/tools.dart';

class DeduplicateShared {
  static String getOtherImageId(String currentItemId, ExtensionData data) {
    if (isNullOrWhitespace(currentItemId)) return "";
    if (data.primaryId == currentItemId) {
      return data.secondaryId;
    } else {
      return data.primaryId;
    }
  }


}