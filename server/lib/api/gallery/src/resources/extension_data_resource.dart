import 'dart:async';
import 'dart:convert';

import 'package:dartlery_shared/global.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/model/model.dart';
import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';
import '../responses/paginated_extension_data_response.dart';
import 'package:server/api/api.dart';
import 'package:server/server.dart';

class ExtensionDataResource extends AResource {
  static final Logger _log = new Logger('ExtensionDataResource');

  final ExtensionDataModel _extensionDataModel;

  ExtensionDataResource(this._extensionDataModel);

  @override
  Logger get childLogger => _log;
  @override
  String get resourcePath => extensionDataApiPath;

  @ApiMethod(
      method: HttpMethod.get,
      path: '$extensionDataApiPath/{extensionId}/{key}/')
  Future<PaginatedExtensionDataResponse> get(String extensionId, String key,
      {bool orderByValues: false,
      bool orderDescending: false,
      int page: 0,
      int perPage: defaultPerPage}) async {
    return await catchExceptionsAwait(() async {
      return new PaginatedExtensionDataResponse.fromPaginatedData(
          await _extensionDataModel.get(extensionId, key,
              orderByValues: orderByValues,
              orderDescending: orderDescending,
              page: page,
              perPage: perPage)
            ..forEach((ExtensionData data) {
              data.externalValue = JSON.encode(data.value);
            }));
    });
  }

  @ApiMethod(
      method: HttpMethod.get,
      path:
          '$extensionDataApiPath/{extensionId}/{key}/{primaryId}/{secondaryId}/')
  Future<PaginatedExtensionDataResponse> getByPrimaryAndSecondaryId(
      String extensionId,
      String key,
      String primaryId,
      String secondaryId) async {
    return await catchExceptionsAwait(() async {
      return new PaginatedExtensionDataResponse.fromPaginatedData(
          await _extensionDataModel.get(extensionId, key,
              primaryId: primaryId, secondaryId: secondaryId)
            ..forEach((ExtensionData data) {
              data.externalValue = JSON.encode(data.value);
            }));
    });
  }

  @ApiMethod(
      method: HttpMethod.delete,
      path:
          '$extensionDataApiPath/{extensionId}/{key}/{primaryId}/{secondaryId}/')
  Future<Null> delete(String extensionId, String key, String primaryId,
      String secondaryId) async {
    return await catchExceptionsAwait(() async {
      await _extensionDataModel.delete(extensionId, key,
          primaryId: primaryId, secondaryId: secondaryId);
    });
  }

  @ApiMethod(
      method: HttpMethod.get,
      path: '$extensionDataApiPath/{extensionId}/{key}/{primaryId}/')
  Future<PaginatedExtensionDataResponse> getByPrimaryId(
      String extensionId, String key, String primaryId,
      {bool bidirectional,
      bool orderByValues: false,
      bool orderDescending: false,
      int page: 0,
      int perPage: defaultPerPage}) async {
    return await catchExceptionsAwait<PaginatedExtensionDataResponse>(() async {
      PaginatedData<ExtensionData> output;
      if (bidirectional) {
        output = await _extensionDataModel.getBidrectional(
            extensionId, key, primaryId,
            orderByValues: orderByValues,
            orderDescending: orderDescending,
            perPage: perPage,
            page: page);
      } else {
        output = await _extensionDataModel.get(extensionId, key,
            primaryId: primaryId,
            orderDescending: orderDescending,
            orderByValues: orderByValues,
            perPage: perPage,
            page: page);
      }
      output.forEach((ExtensionData data) {
        data.externalValue = JSON.encode(data.value);
      });
      return new PaginatedExtensionDataResponse.fromPaginatedData(output);
    });
  }
}
