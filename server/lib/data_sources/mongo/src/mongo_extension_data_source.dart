import 'dart:async';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:dartlery_shared/global.dart';
import 'a_mongo_two_id_data_source.dart';
import 'constants.dart';
import 'package:option/option.dart';
import 'a_mongo_data_source.dart';

class MongoExtensionDataSource extends AMongoObjectDataSource<ExtensionData>
    with AExtensionDataSource {
  static final Logger _log = new Logger('MongoExtensionDataSource');
  @override
  Logger get childLogger => _log;

  static const String extensionIdField = 'extensionId';
  static const String keyField = "key";
  static const String primaryIdField = "primaryId";
  static const String secondaryIdField = "secondaryId";
  static const String valueField = "value";
  static const String inTrashField = "inTrash";

  MongoExtensionDataSource(MongoDbConnectionPool pool) : super(pool);

  @override
  Future<DbCollection> getCollection(MongoDatabase con) =>
      con.getExtensionDataCollection();

  @override
  Future<Null> create(ExtensionData data) async {
    await insertIntoDb(data);
  }

  @override
  Future<Null> update(ExtensionData data) async {
    final SelectorBuilder query = _generateQuery(
        data.extensionId, data.key, data.primaryId, data.secondaryId, true);

    await updateToDb(query, data);
  }

  SelectorBuilder _generateQuery(String extensionId, String key,
      String primaryId, String secondaryId, bool setNulls) {
    if (isNullOrWhitespace(primaryId) && isNotNullOrWhitespace(secondaryId))
      throw new ArgumentError("primaryId required if specifying a secondaryId");

    final SelectorBuilder query =
        where.eq(extensionIdField, extensionId).eq(keyField, key);

    if (isNotNullOrWhitespace(primaryId))
      query.eq(primaryIdField, primaryId);
    else if (setNulls) query.eq(primaryIdField, null);

    if (isNotNullOrWhitespace(secondaryId))
      query.eq(secondaryIdField, secondaryId);
    else if (setNulls) query.eq(secondaryIdField, null);

    return query;
  }

  @override
  Future<Null> delete(String extensionId, String key,
      {String primaryId, String secondaryId, bool useNullIds: false}) async {
    await deleteFromDb(
        _generateQuery(extensionId, key, primaryId, secondaryId, useNullIds));
  }

  @override
  Future<Null> deleteBidirectional(
      String extensionId, String key, String bidirectionalId) async {
    final SelectorBuilder query = where
        .eq(extensionIdField, extensionId)
        .eq(keyField, key)
        .and(where
            .eq(primaryIdField, bidirectionalId)
            .or(where.eq(secondaryIdField, bidirectionalId)));
    await deleteFromDb(query);
  }

  @override
  Future<bool> hasData(String extensionId, String key,
      {String primaryId, String secondaryId, bool useNullIds: false}) async {
    return await exists(
        _generateQuery(extensionId, key, primaryId, secondaryId, useNullIds));
  }

  @override
  Future<PaginatedData<ExtensionData>> getBidrectional(
      String extensionId, String key, String bidirectionalId,
      {bool orderByValues: false,
      bool orderDescending: false,
      int page: 0,
      int perPage}) async {
    final SelectorBuilder query = where
        .eq(extensionIdField, extensionId)
        .eq(keyField, key)
        .and(where
            .eq(primaryIdField, bidirectionalId)
            .or(where.eq(secondaryIdField, bidirectionalId)));
    if (orderByValues)
      query.sortBy(valueField, descending: orderDescending);
    else
      query
          .sortBy(primaryIdField, descending: orderDescending)
          .sortBy(secondaryIdField, descending: orderDescending);

    return await getPaginatedFromDb(query);
  }

  @override
  Future<PaginatedData<ExtensionData>> get(String extensionId, String key,
      {String primaryId,
      String secondaryId,
      bool useNullIds: false,
      bool orderByValues: false,
      bool orderByIds: false,
      bool orderDescending: false,
      int page: 0,
      int perPage: defaultPerPage}) async {
    final SelectorBuilder query =
        _generateQuery(extensionId, key, primaryId, secondaryId, useNullIds);
    if (orderByIds)
      query
          .sortBy(primaryIdField, descending: orderDescending)
          .sortBy(secondaryIdField, descending: orderDescending);
    if (orderByValues) query.sortBy(valueField, descending: orderDescending);

    if (!orderByIds && !orderByValues)
      query.sortBy(internalIdField, descending: orderDescending);

    return await getPaginatedFromDb(query);
  }

  @override
  void updateMap(ExtensionData item, Map<String, dynamic> data) {
    data[extensionIdField] = item.extensionId;
    data[keyField] = item.key;
    data[primaryIdField] = item.primaryId;
    data[secondaryIdField] = item.secondaryId;
    data[valueField] = item.value;
  }

  @override
  Future<ExtensionData> createObject(Map<String, dynamic> data) async {
    final ExtensionData output = new ExtensionData();
    output.extensionId = data[extensionIdField];
    output.key = data[keyField];
    output.primaryId = data[primaryIdField];
    output.secondaryId = data[secondaryIdField];
    output.value = data[valueField];
    return output;
  }
}
