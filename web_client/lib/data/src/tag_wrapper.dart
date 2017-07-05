import 'package:dartlery/api/api.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery_shared/global.dart';

class TagWrapper {
  Tag _tag;
  TagInfo _tagInfo;

  Tag get tag {
    if (_tag != null) {
      return _tag;
    }
    final Tag output = new Tag();
    output.id = this.id;
    output.category = this.category;
    return output;
  }

  String get id => _tag?.id ?? _tagInfo.id;
  String get category => _tag?.category ?? _tagInfo?.category;
  int get count => _tagInfo?.count;
  bool get hasCategory => isNotNullOrWhitespace(category);
  TagWrapper get redirect {
    if (_tagInfo == null || _tagInfo.redirect == null) {
      return null;
    }
    return new TagWrapper.fromTag(_tagInfo.redirect);
  }

  TagWrapper.fromTag(this._tag);
  TagWrapper.fromTagInfo(this._tagInfo);

  @override
  String toString() => format(id, category);

  static String format(String id, [String category]) {
    if (isNotNullOrWhitespace(category)) {
      return "$category$categoryDeliminator $id";
    } else {
      return id;
    }
  }

  static String formatTag(Tag tag) => format(tag.id, tag.category);
  static String formatTagInfo(TagInfo tag) => format(tag.id, tag.category);

  static String createQueryStringForTag(Tag t) =>
      createQueryString(t.id, t.category);

  static String createQueryString(String id, [String category]) {
    if (id == null) throw new ArgumentError.notNull("id");

    final String tagString =
        Uri.encodeFull(id).replaceAll(":", "%3A").replaceAll(",", "%2C");
    final String categoryString = Uri
        .encodeFull(category ?? "")
        .replaceAll(":", "%3A")
        .replaceAll(",", "%2C");
    if (isNotNullOrWhitespace(categoryString)) {
      return "$categoryString$categoryDeliminator$tagString";
    } else {
      return tagString;
    }
  }

  String toQueryString() => createQueryString(this.id, this.category);

  bool equals(TagWrapper other) {
    if (id?.toLowerCase() == other.id?.toLowerCase() &&
        category?.toLowerCase() == other.category?.toLowerCase()) {
      return true;
    }
    return false;
  }
}
