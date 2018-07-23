import 'a_data.dart';

class AIdData extends AData {
  static const String idField = "id";

  @DbField(name: AIdData.idField)
  String id;

  AIdData();

  AIdData.withValues(this.id);

  AIdData.copy(dynamic o) {
    this.id = o.id;
  }
}
