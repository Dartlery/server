import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/data/data.dart';
import 'a_id_based_data_source.dart';

abstract class AItemDataSource extends AIdBasedDataSource<Item> {
  static final Logger _log = new Logger('AItemDataSource');

  Future<IdDataList<Item>> getVisible(String userUuid);
  Future<IdDataList<Item>> searchVisible(String userUuid, String query);
  Future<PaginatedIdData<Item>> getVisiblePaginated(String userUuid,
      {int page: 0, int perPage: defaultPerPage});
  Future<PaginatedIdData<Item>> searchVisiblePaginated(
      String userUuid, String query,
      {int page: 0, int perPage: defaultPerPage});
}