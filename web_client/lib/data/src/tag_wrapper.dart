import 'package:dartlery/api/api.dart';
import 'package:dartlery_shared/tools.dart';

class TagWrapper {
  final Tag tag;

  TagWrapper(this.tag);

  @override
  String toString() {
    if(StringTools.isNotNullOrWhitespace(tag.category)) {
      return "${tag.category}: ${tag.id}";
    } else {
      return tag.id;
    }
  }
}