import 'package:dartlery/api/api.dart';
import 'package:dartlery_shared/tools.dart';

class TagWrapper {
  final Tag tag;

  TagWrapper(this.tag);

  String get id => tag.toString();

  @override
  String toString() {
    if(StringTools.isNotNullOrWhitespace(tag.category)) {
      return "${tag.category}: ${tag.id}";
    } else {
      return tag.id;
    }
  }

  bool equals(TagWrapper other) {
    if(tag.id?.toLowerCase()==other.tag.id?.toLowerCase()
        &&tag.category?.toLowerCase()==other.tag.category?.toLowerCase()) {
      return true;
    }
    return false;
  }
}