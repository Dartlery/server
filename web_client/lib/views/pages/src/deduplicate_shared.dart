import 'package:dartlery/api/api.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery/angular_page_control/angular_page_control.dart';

const PageAction clearSimilarAction = const PageAction(
    "clearSimilar", "clear_all",
    message: const PageMessage(
        "Clear", "Are you sure you want to clear similarities?",
        buttons: PageMessageButtons.yesNo));

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
