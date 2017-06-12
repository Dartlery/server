
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

class SettingsResource extends AResource {
  static final Logger _log = new Logger('SettingsResource');
  static const String _apiPath = "settings";

  @override
  Logger get childLogger => _log;

  final ImportModel _settingsModel;

  SettingsResource(this._settingsModel);

  @ApiMethod(method: HttpMethod.get, path: '$_apiPath/')
  Future<Map<String,String>> get() =>
      catchExceptionsAwait<Map<String,String>>(() async {
            return _settingsModel.get();
      });



  @ApiMethod(method: HttpMethod.patch, path: '$_apiPath/')
  Future<Null> save(Map<String,String> data) =>
      catchExceptionsAwait<Null>(() async {
        return _settingsModel.save(data);
      });

}
