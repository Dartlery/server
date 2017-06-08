import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data/data.dart';
import 'a_two_id_based_data_source.dart';

abstract class ATagDataSource extends ATwoIdBasedDataSource<TagInfo> {
  static final Logger _log = new Logger('ATagDataSource');

  Future<List<TagInfo>> getRedirects();
  Future<List<TagInfo>> getByRedirect(String id, String category);
  Future<Null> deleteByRedirect(String id, String category);

  @override
  Future<IdDataList<Tag>> search(String query, {int limit, bool countAsc: true});

  /// This function should cause all tags to be re-counted
  /// and unused tags to be deleted.
  /// Note: Redirecting tags are not considered unused unless their targets are.
  Future<Null> cleanUpTags();
  Future<int> countTagUse(Tag t);
  Future<Null> incrementTagCount(List<Tag> tags, int amount);
  Future<Null> refreshTagCount(List<Tag> tags);

}
