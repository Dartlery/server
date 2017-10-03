import 'package:dartlery/model/model.dart';
import 'package:logging/logging.dart';
import 'package:server/api/api.dart';

class SettingsResource extends AResource {
  static final Logger _log = new Logger('SettingsResource');
  static const String _apiPath = "settings";

  @override
  Logger get childLogger => _log;

  final ImportModel _settingsModel;

  SettingsResource(this._settingsModel);
//
//  @ApiMethod(method: HttpMethod.get, path: '$_apiPath/')
//  Future<Map<String,String>> get() =>
//      catchExceptionsAwait<Map<String,String>>(() async {
//            return _settingsModel.get();
//      });
//
//
//
//  @ApiMethod(method: HttpMethod.patch, path: '$_apiPath/')
//  Future<Null> save(Map<String,String> data) =>
//      catchExceptionsAwait<Null>(() async {
//        return _settingsModel.save(data);
//      });

}
