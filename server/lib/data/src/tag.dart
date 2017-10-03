import 'package:tools/tools.dart';
import 'package:rpc/rpc.dart';

import 'package:server/data/data.dart';
import 'package:dartlery_shared/global.dart';

@ApiMessage(includeSuper: true)
class Tag extends AIdData {
  @ApiProperty(ignore: true)
  dynamic internalId;

  String category;

  Tag();

  Tag.withValues(String name, [this.category]) : super.withValues(name);

  static Tag parse(String tagString) {
    if (tagString.contains(";")) {
      final List<String> parts = tagString.split(categoryDeliminator);
      return new Tag.withValues(
          parts.sublist(1).join(categoryDeliminator).trim(), parts[0].trim());
    } else {
      return new Tag.withValues(tagString);
    }
  }

  String get fullName => formatTag(id, category);

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
    if (id?.toLowerCase() == other.id?.toLowerCase()) {
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
