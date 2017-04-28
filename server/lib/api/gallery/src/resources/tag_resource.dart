import 'dart:async';

import 'package:dartlery/api/api.dart';
import 'package:dartlery/model/model.dart';
import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';
import 'package:dartlery/data/data.dart';

class TagResource extends AResource {
  static final Logger _log = new Logger('TagResource');

  @override
  String get resourcePath => tagApiPath;

  @override
  Logger get childLogger => _log;

  final TagModel _tagModel;
  TagResource(this._tagModel);

  @ApiMethod(method: 'GET', path: '$setupApiPath/search/{query}')
  Future<List<Tag>> search(String query) async {
    return catchExceptionsAwait(() async {
      return await _tagModel.search(query);
    });
  }
}
