import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/data/data.dart';
import 'a_id_based_data_source.dart';

abstract class AItemDataSource extends AIdBasedDataSource<Item> {
  static final Logger _log = new Logger('AItemDataSource');

  Future<Null> updateTags(String id, List<Tag> tags);
  Future<IdDataList<Item>> getVisible(String userUuid, {bool inTrash: false});

  Future<List<Item>> getVisibleRandom(String userUuid,
      {List<Tag> filterTags,
      int perPage: defaultPerRandomPage,
      bool inTrash: false,
      bool imagesOnly: false});

  Future<IdDataList<Item>> searchVisible(String userUuid, String query,
      {bool inTrash: false});

  Future<PaginatedIdData<Item>> getVisiblePaginated(String userUuid,
      {int page: 0,
      int perPage: defaultPerPage,
      DateTime cutoffDate,
      bool inTrash: false});

  Future<PaginatedIdData<Item>> getAllPaginated(
      {int page: 0,
      int perPage: defaultPerPage,
      bool sortDescending: true,
      bool inTrash: false});

  Future<PaginatedIdData<Item>> searchVisiblePaginated(
      String userUuid, List<Tag> tags,
      {int page: 0,
      int perPage: defaultPerPage,
      DateTime cutoffDate,
      bool inTrash: false});

  Future<Null> setTrashStatus(String id, bool inTrash);

  Future<Stream<Item>> streamByMimeType(String mimeType);

  Future<Stream<Item>> streamAll(
      {bool addedDesc: true, DateTime startDate, int limit});

  Future<Null> replaceTags(List<Tag> originalTags, List<Tag> newTags);
}
