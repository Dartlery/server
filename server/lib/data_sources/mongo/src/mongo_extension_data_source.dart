import 'dart:async';
import 'package:tools/tools.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:dartlery_shared/global.dart';
import 'package:server/data_sources/mongo/mongo.dart';
import '../mongo.dart';
import 'package:server/data/data.dart';
import 'package:server/server.dart';

class MongoExtensionDataSource extends AMongoObjectDataSource<ExtensionData>
    with AExtensionDataSource {
  static final Logger _log = new Logger('MongoExtensionDataSource');
  @override
  Logger get childLogger => _log;


  MongoExtensionDataSource(MongoDbConnectionPool pool) : super(pool);

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
        where.eq(ExtensionData.extensionIdField, extensionId).eq(ExtensionData.keyField, key);

    if (isNotNullOrWhitespace(primaryId))
      query.eq(ExtensionData.primaryIdField, primaryId);
    else if (setNulls) query.eq(ExtensionData.primaryIdField, null);

    if (isNotNullOrWhitespace(secondaryId))
      query.eq(ExtensionData.secondaryIdField, secondaryId);
    else if (setNulls) query.eq(ExtensionData.secondaryIdField, null);

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
        .eq(ExtensionData.extensionIdField, extensionId)
        .eq(ExtensionData.keyField, key)
        .and(where
            .eq(ExtensionData.primaryIdField, bidirectionalId)
            .or(where.eq(ExtensionData.secondaryIdField, bidirectionalId)));
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
        .eq(ExtensionData.extensionIdField, extensionId)
        .eq(ExtensionData.keyField, key)
        .and(where
            .eq(ExtensionData.primaryIdField, bidirectionalId)
            .or(where.eq(ExtensionData.secondaryIdField, bidirectionalId)));
    if (orderByValues)
      query.sortBy(ExtensionData.valueField, descending: orderDescending);
    else
      query
          .sortBy(ExtensionData.primaryIdField, descending: orderDescending)
          .sortBy(ExtensionData.secondaryIdField, descending: orderDescending);

    return await getPaginatedFromDb(query);
  }

  @override
  Future<PaginatedData<ExtensionData>> get(String extensionId, String key,
      {String primaryId,
      String secondaryId,
      bool useNullIds: false,
      bool orderByValues: false,
      bool orderDescending: false,
      int page: 0,
      int perPage: defaultPerPage}) async {
    final SelectorBuilder query =
        _generateQuery(extensionId, key, primaryId, secondaryId, useNullIds);
    if (orderByValues)
      query.sortBy(ExtensionData.valueField, descending: orderDescending);
    else
      query
          .sortBy(ExtensionData.primaryIdField, descending: orderDescending)
          .sortBy(ExtensionData.secondaryIdField, descending: orderDescending);

    return await getPaginatedFromDb(query);
  }

}
