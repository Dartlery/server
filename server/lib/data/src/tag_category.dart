import 'a_id_data.dart';
import 'package:option/option.dart';
import 'tag.dart';
import 'package:rpc/rpc.dart';

@ApiMessage(includeSuper: true)
class TagCategory extends AIdData {
  String color = "#000000";

  TagCategory();
  TagCategory.withValues(String id, {this.color}): super.withValues(id);
}