import 'dart:async';
import 'dart:io';

import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/data_sources/mongo/mongo.dart' as mongo;
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';

import 'a_model.dart';
import 'a_typed_model.dart';

import 'package:dice/dice.dart';
@Injectable()
class ExtensionDataModel extends ATypedModel<ExtensionData> {
  static final Logger _log = new Logger('ExtensionDataModel');

  AExtensionDataSource _extensionDataSource;

  @inject
  ExtensionDataModel(this._extensionDataSource, AUserDataSource userDataSource)
      : super(userDataSource);

  @override
  Logger get loggerImpl => _log;

  Future<Null> delete(String extensionId, String key,
          {String primaryId, String secondaryId}) =>
      _extensionDataSource.delete(extensionId, key,
          primaryId: primaryId, secondaryId: secondaryId);

  Future<Null> deleteBidirectional(
          String extensionId, String key, String bidirectionalId) =>
      _extensionDataSource.deleteBidirectional(
          extensionId, key, bidirectionalId);

  Future<PaginatedData<ExtensionData>> get(String extensionId, String key,
      {String primaryId,
      String secondaryId,
      bool orderByValues: false,
      bool orderByIds: false,
      bool orderDescending: false,
      int page: 0,
      int perPage: defaultPerPage}) async {
    final PaginatedData<ExtensionData> output = await _extensionDataSource.get(
        extensionId, key,
        primaryId: primaryId,
        secondaryId: secondaryId,
        orderByValues: orderByValues,
        orderByIds: orderByIds,
        orderDescending: orderDescending,
        page: page,
        perPage: perPage);
    if (output.isEmpty)
      throw new NotFoundException("Specified extension data was not found");
    return output;
  }

  Future<PaginatedData<ExtensionData>> getBidrectional(
      String extensionId, String key, String bidirectionalId,
      {bool orderByValues: false,
      bool orderDescending: false,
      int page: 0,
      int perPage: defaultPerPage}) async {
    final PaginatedData<ExtensionData> output = await _extensionDataSource
        .getBidrectional(extensionId, key, bidirectionalId,
            orderDescending: orderDescending,
            orderByValues: orderByValues,
            perPage: perPage,
            page: page);
    if (output.isEmpty)
      throw new NotFoundException("Specified extension data was not found");
    return output;
  }

  Future<ExtensionData> getSpecific(String extensionId, String key,
      {String primaryId, String secondaryId}) async {
    final PaginatedData<ExtensionData> output = await _extensionDataSource.get(
        extensionId, key,
        primaryId: primaryId, secondaryId: secondaryId, useNullIds: true);
    if (output.isEmpty)
      throw new NotFoundException("Specified extension data was not found");
    return output.first;
  }

  Future<Null> set(ExtensionData data) async {
    await validate(data);
    if (await _extensionDataSource.hasData(data.extensionId, data.key,
        primaryId: data.primaryId,
        secondaryId: data.secondaryId,
        useNullIds: true))
      await _extensionDataSource.update(data);
    else
      await _extensionDataSource.create(data);
  }

  @override
  Future<Null> validateFields(ExtensionData data, Map<String, String> output,
      {String existingId: null}) async {
    if (isNullOrWhitespace(data.extensionId))
      output["extensionId"] = "Required";

    if (isNullOrWhitespace(data.key)) output["key"] = "Required";

    if (isNullOrWhitespace(data.primaryId) &&
        isNotNullOrWhitespace(data.secondaryId))
      output["primaryId"] = "Required";
  }
}
