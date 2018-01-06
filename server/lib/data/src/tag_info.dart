import 'tag.dart';
import 'package:rpc/rpc.dart';
import 'package:orm/meta.dart';

@ApiMessage(includeSuper: true)
@DbStorage("tags")
class TagInfo extends Tag {
  @DbField()
  int count;
  @DbField()
  Tag redirect;

  TagInfo();

  TagInfo.copy(Tag other, [this.redirect])
      : super.withValues(other.id, other.category);
  TagInfo.withValues(String id, [String category])
      : super.withValues(id, category);
}
