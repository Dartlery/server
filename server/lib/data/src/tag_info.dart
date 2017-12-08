import 'tag.dart';
import 'package:rpc/rpc.dart';
import 'package:server/data_sources/data_sources.dart';

@ApiMessage(includeSuper: true)
class TagInfo extends Tag {
  static const String redirectField = "redirect";
  static const String countField = "count";

  int count;
  @DbIndex("RedirectIndex", sparse: true)
  Tag redirect;

  TagInfo();

  TagInfo.copy(Tag other, [this.redirect])
      : super.withValues(other.name, other.category);
  TagInfo.withValues(String id, [String category])
      : super.withValues(id, category);
}
