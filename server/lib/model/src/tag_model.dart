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

import 'a_typed_model.dart';

class TagModel extends ATypedModel<Tag> {
  static final Logger _log = new Logger('UserModel');

  final ATagDataSource _tagDataSource;

  final ATagCategoryDataSource _tagCategoryDataSource;
  TagModel(this._tagDataSource, this._tagCategoryDataSource,
      AUserDataSource userDataSource)
      : super(userDataSource);

  @override
  Logger get loggerImpl => _log;

  Future<List<Tag>> search(String query) async {
    final List<Tag> output = await _tagDataSource.search(query);
    return output;
  }

  @override
  Future<Null> validateFields(Tag tag, Map<String, String> fieldErrors,
      {String existingId: null}) async {
    //TODO: add dynamic field validation
    await super.validateFields(tag, fieldErrors);

    if (StringTools.isNotNullOrWhitespace(tag.category)) {
      final bool result = await _tagCategoryDataSource.existsById(tag.category);
      if (!result) {
        fieldErrors["category"] = "Not found";
      }
    }
  }
}
