import 'package:server/data/data.dart';
import 'package:option/option.dart';
import 'tag.dart';
import 'package:rpc/rpc.dart';

@ApiMessage(includeSuper: true)
class TagCategory extends AIdData {
  String color = "#000000";

  TagCategory();
  TagCategory.withValues(String id, {this.color: '#000000'})
      : super.withValues(id);
}
