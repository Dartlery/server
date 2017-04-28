import 'package:dartlery/api/api.dart';
import 'package:dartlery/client.dart';
import 'package:dartlery_shared/global.dart';

class ItemEditField {
  bool imageLoading = false;
  String editImageUrl = "";
  String displayImageUrl = "";

  MediaMessage mediaMessage;
  Field field;

  String _value = "";
  ItemEditField(this.field, [ImportResult result]) {
    if (result != null) {
      this.value = getImportResultValue(result, field.id);
    }
  }
  String get uuid => field.id;
  bool get isTypeImage => field.type == "image";

  bool get isTypeString => field.type == "string" || field.type == "hidden";

  String get name => field.name;

  String get type => field.type;

  String get value => _value;

  set value(String value) {
    _value = value;
    if (isTypeImage) {
      this.displayImageUrl = getImageUrl(value, ImageType.thumbnail);
      if (!value.startsWith(hostedFilesPrefix)) editImageUrl = value;
    }
  }

  static Iterable<ItemEditField> createList(List<Field> fields,
      [ImportResult result]) {
    return fields.map<ItemEditField>((Field f) => new ItemEditField(f, result));
  }

  static String getImportResultValue(ImportResult result, String name) {
    if (result == null ||
        !result.values.containsKey(name) ||
        result.values[name].length == 0) return "";
    return result.values[name][0];
  }
}
