import 'package:dartlery_shared/global.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data/data.dart';
import 'package:server/data_sources/interfaces.dart';
import 'package:server/data/data.dart';
import 'package:server/server.dart';

abstract class ATagDataSource extends ATwoIdBasedDataSource<TagInfo> {
  static final Logger _log = new Logger('ATagDataSource');

  Future<List<TagInfo>> getRedirects();
//  Future<List<TagInfo>> getByRedirect(String id, String category);
  Future<Null> deleteByRedirect(String id, String category);

  @override
  Future<PaginatedData<TagInfo>> getAllPaginated(
      {int page: 0, int perPage: defaultPerPage, bool countAsc: null});

  @override
  Future<IdDataList<TagInfo>> search(String query,
      {int limit: defaultPerPage, bool countAsc: null, bool redirects: null});

  Future<PaginatedData<TagInfo>> searchPaginated(String query,
      {int page: 0,
      int perPage: defaultPerPage,
      bool countAsc: null,
      bool redirects: null});

  /// This function should cause all tags to be re-counted
  /// and unused tags to be deleted.
  /// Note: Redirecting tags are not considered unused unless their targets are.
  Future<Null> cleanUpTags();
  Future<int> countTagUse(Tag t);
  Future<Null> incrementTagCount(List<Tag> tags, int amount);
  Future<Null> refreshTagCount(List<Tag> tags);
}
