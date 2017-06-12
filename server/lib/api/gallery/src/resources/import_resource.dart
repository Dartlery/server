import 'dart:async';

import 'package:dartlery/api/api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery/tools.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';

import '../../gallery_api.dart';
import '../requests/create_item_request.dart';
import '../requests/item_search_request.dart';
import '../requests/update_item_request.dart';
import 'dart:convert';
import '../responses/paginated_import_results_response.dart';
import '../requests/import_path_request.dart';

class ImportResource extends AResource {
  static final Logger _log = new Logger('ItemResource');
  static const String _apiPath = "import";

  @override
  Logger get childLogger => _log;

  final ImportModel _importModel;

  ImportResource(this._importModel);

  @ApiMethod(method: HttpMethod.post, path: '$_apiPath/results/')
  Future<StringResponse> importFromPath(ImportPathRequest request) =>
      catchExceptionsAwait<StringResponse>(() async {
        return new StringResponse((await _importModel.enqueueImportFromPath(
                request.path,
                interpretShimmieNames: request.interpretShimmieNames,
                stopOnError: request.stopOnError))
            .toString());
      });

  @ApiMethod(method: HttpMethod.get, path: '$_apiPath/results/')
  Future<PaginatedImportResultsResponse> getResults(
          {int page: 0, int perPage: defaultPerPage}) =>
      catchExceptionsAwait<PaginatedImportResultsResponse>(() async {
        return new PaginatedImportResultsResponse.fromPaginatedData(
            await _importModel.getResults(page: page, perPage: perPage));
      });

  @ApiMethod(method: HttpMethod.delete, path: '$_apiPath/results/')
  Future<Null> clearResults({bool everything: false}) =>
      catchExceptionsAwait<Null>(() async {
        await _importModel.clearResults(everything);
      });
}
