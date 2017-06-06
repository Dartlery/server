import 'package:dartlery/api/api.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery_shared/global.dart';

class TagWrapper {
  Tag _tag;
  TagInfo _tagInfo;

  Tag get tag {
    if(_tag!=null) {
      return _tag;
    }
    final Tag output = new Tag();
    output.id=this.id;
    output.category==this.category;
    return output;
  }

  String get id => _tag?.id??_tagInfo.id;
  String get category => _tag?.category??_tagInfo?.category;

  TagWrapper.fromTag(this._tag);
  TagWrapper.fromTagInfo(this._tagInfo);

  @override
  String toString() =>format(id, category);


  static String format(String id, [String category]) {
    if(StringTools.isNotNullOrWhitespace(category)) {
      return "$category$categoryDeliminator $id";
    } else {
      return id;
    }
  }

  static String formatTag(Tag tag) => format(tag.id, tag.category);
  static String formatTagInfo(TagInfo tag) => format(tag.id, tag.category);

  static String createQueryString(Tag tag) {
    if(tag==null)
      throw new ArgumentError.notNull("tag");

    final String tagString = Uri.encodeFull(tag.id).replaceAll(":", "%3A").replaceAll(",","%2C");
    final String categoryString = Uri.encodeFull(tag.category??"").replaceAll(":", "%3A").replaceAll(",","%2C");
    if(StringTools.isNotNullOrWhitespace(categoryString)) {
      return "$categoryString$categoryDeliminator$tagString";
    } else {
      return tagString;
    }
  }

  String toQueryString() => createQueryString(tag);

  bool equals(TagWrapper other) {
    if(id?.toLowerCase()==other.id?.toLowerCase()
        &&category?.toLowerCase()==other.category?.toLowerCase()) {
      return true;
    }
    return false;
  }
}