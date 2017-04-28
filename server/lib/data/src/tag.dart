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
  String category;

  Tag();

  Tag.withValues(String name, {this.category}):
        super.withValues(name);

}

