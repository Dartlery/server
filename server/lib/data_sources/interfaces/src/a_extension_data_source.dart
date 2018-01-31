import 'dart:async';
import 'package:logging/logging.dart';
import 'a_data_source.dart';
import 'package:dartlery/data/data.dart';
import 'package:option/option.dart';

abstract class AExtensionDataSource extends ADataSource {
  static final Logger _log = new Logger('AExtensionDataSource');

  Future<Null> create(ExtensionData data);
  Future<Null> update(ExtensionData data);
  Future<Null> delete(String extensionId, String key,
      {String primaryId, String secondaryId, bool useNullIds: false});
  Future<Null> deleteBidirectional(
      String extensionId, String key, String bidirectionalId);
  Future<PaginatedData<ExtensionData>> get(String extensionId, String key,
      {String primaryId,
      String secondaryId,
      bool useNullIds: false,
      bool orderByValues: false,
      bool orderByIds: false,
      bool orderDescending: false,
      int page: 0,
      int perPage});
  Future<PaginatedData<ExtensionData>> getBidrectional(
      String extensionId, String key, String birectionalID,
      {bool orderByValues: false,
      bool orderDescending: false,
      int page: 0,
      int perPage});


  Future<bool> hasData(String extensionId, String key,
      {String primaryId, String secondaryId, bool useNullIds: false});
}
