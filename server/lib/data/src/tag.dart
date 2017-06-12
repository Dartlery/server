import 'package:dartlery_shared/tools.dart';
import 'package:option/option.dart';
import 'package:rpc/rpc.dart';

import 'a_id_data.dart';
import 'tag_category.dart';
import 'package:dartlery_shared/global.dart';

@ApiMessage(includeSuper: true)
class Tag extends AIdData {
  @ApiProperty(ignore: true)
  dynamic internalId;

  String category;

  Tag();

  Tag.withValues(String name, [this.category]) : super.withValues(name);

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
