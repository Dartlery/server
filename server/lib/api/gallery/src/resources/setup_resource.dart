import 'dart:async';

import 'package:dartlery/api/api.dart';
import 'package:dartlery/model/model.dart';
import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';
import '../responses/setup_response.dart';
import '../requests/setup_request.dart';

class SetupResource extends AResource {
  static final Logger _log = new Logger('SetupResource');

  @override
  String get resourcePath => setupApiPath;

  @override
  Logger get childLogger => _log;

  final SetupModel setupModel;
  SetupResource(this.setupModel);

  @ApiMethod(method: 'PUT', path: '$setupApiPath/')
  Future<SetupResponse> apply(SetupRequest request) async {
    return catchExceptionsAwait(() async {
      return await setupModel.apply(request);
    });
  }

  @ApiMethod(method: 'GET', path: '$setupApiPath/')
  Future<SetupResponse> get() async {
    return catchExceptionsAwait(() async {
      return await setupModel.checkSetup();
    });
  }
}
