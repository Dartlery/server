import 'tag.dart';
import 'package:rpc/rpc.dart';

@ApiMessage(includeSuper: true)
class TagInfo extends Tag {
  int count;
  Tag redirect;

  TagInfo();

  TagInfo.copy(Tag other, [ this.redirect ]): super.withValues(other.id, other.category);
  TagInfo.withValues(String id, [String category]): super.withValues(id, category);
}