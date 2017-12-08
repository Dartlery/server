import 'package:tools/tools.dart';
import 'package:rpc/rpc.dart';
import 'package:server/data_sources/data_sources.dart';

import 'package:server/data/data.dart';
import 'package:dartlery_shared/global.dart';

@ApiMessage(includeSuper: true)
class Tag extends AData  {
  static const String categoryField = 'category';
  static const String fullNameField = "fullName";
  static const String idIndex = "IdIndex";

  @ApiProperty(ignore: true)
  dynamic internalId;

  @DbIndex(idIndex, unique: true, order: 0)
  @DbField(name: "id")
  String name;
  @DbIndex(idIndex, unique: true, order: 1)
  String category;



  Tag();

  Tag.withValues(this.name, [this.category]);

  static Tag parse(String tagString) {
    if (tagString.contains(";")) {
      final List<String> parts = tagString.split(categoryDeliminator);
      return new Tag.withValues(
          parts.sublist(1).join(categoryDeliminator).trim(), parts[0].trim());
    } else {
      return new Tag.withValues(tagString);
    }
  }

  @DbIndex("TagTextIndex", text: true)
  String get fullName => formatTag(name, category);

  static String formatTag(String id, [String category]) {
    if (isNotNullOrWhitespace(category)) {
      return "$category$categoryDeliminator $id";
    } else {
      return id;
    }
  }

  @ApiProperty(ignore: true)
  bool get hasCategory => isNotNullOrWhitespace(this.category);

  set fullName(String value) {}

  bool equals(Tag other) {
    if (name?.toLowerCase() == other.name?.toLowerCase()) {
      if (category?.toLowerCase() == other.category?.toLowerCase() ||
          (isNullOrWhitespace(this.category) &&
              isNullOrWhitespace(other.category))) return true;
    }

    return false;
  }

  @override
  String toString() => fullName;

  @override
  bool operator ==(Tag other) => equals(other);
}
