import 'a_id_data.dart';
import 'package:option/option.dart';
import 'tag_category.dart';
import 'package:rpc/rpc.dart';
import 'package:dartlery_shared/tools.dart';

@ApiMessage(includeSuper: true)
class Tag extends AIdData {
  String get fullName {
    if(StringTools.isNotNullOrWhitespace(category)) {
      return "$category: $id";
    } else {
      return id;
    }
  }
  set fullName(String value) {} // Only here so that the API will generate it as a field

  String category;

  Tag();

  Tag.withValues(String name, {this.category}):
        super.withValues(name);

  bool equals(Tag other) {
    if(id?.toLowerCase()==other.id?.toLowerCase()
        &&category?.toLowerCase()==other.category?.toLowerCase()) {
      return true;
    }
    return false;
  }

  @override
  String toString() => fullName;
}

