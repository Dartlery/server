import 'package:server/data/data.dart';
import 'dart:async';
import 'package:dartlery/data/data.dart';

class GlobalSettings extends AData {
  /// Controls whether items are visible to non-logged in users by default.
  bool publicVisible = false;

  /// If [publicVisible] is set to [false], then [publicTags] specifies what
  /// [Tag]s indicate that an item should be publicly visible.
  List<Tag> publicTags;

  /// Specifies the [Tag]s that indicate an item should only be visible to the
  /// person who posted it.
  List<Tag> privateTags;

  GlobalSettings();

  Future validate() async {}
}
