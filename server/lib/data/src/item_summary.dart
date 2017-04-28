import 'item.dart';

class ItemSummary {
  String uuid = "";
  String typeUuid = "";
  String thumbnail = "";

  ItemSummary();

  ItemSummary.copyObject(dynamic field) {
    _copy(field, this);
  }

  ItemSummary.copyItem(Item o) {
    this.uuid = o.id;
    this.thumbnail = o.fileThumbnail;
  }

  void copyTo(dynamic output) {
    _copy(this, output);
  }

  void _copy(dynamic from, dynamic to) {
    to.id = from.id;
    to.name = from.name;
    to.typeUuid = from.typeUuid;
    to.thumbnail = from.thumbnail;
  }

  static List<ItemSummary> convertItemList(Iterable<Item> i) {
    final List<ItemSummary> output = new List<ItemSummary>();
    for (Item o in i) {
      output.add(new ItemSummary.copyItem(o));
    }
    return output;
  }

  static List<ItemSummary> convertObjectList(Iterable<dynamic> input) {
    final List<ItemSummary> output = new List<ItemSummary>();
    for (dynamic obj in input) {
      output.add(new ItemSummary.copyObject(obj));
    }
    return output;
  }
}
