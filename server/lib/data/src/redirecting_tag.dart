import 'tag.dart';
import 'package:rpc/rpc.dart';

@ApiMessage(includeSuper: true)
class RedirectingTag extends Tag {
  Tag redirect;

  RedirectingTag();

  RedirectingTag.copy(Tag other, this.redirect): super.withValues(other.id, category: other.category);
}