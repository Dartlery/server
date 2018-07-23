import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:meta/meta.dart';
import 'package:orm/orm.dart';

import 'a_model.dart';

abstract class ATypedModel<T,I> extends AModel {
  ATypedModel(DatabaseContext db) : super(db);

  Future<Null> validate(T t, {I existingId: null}) =>
      DataValidationException.performValidation(
          (Map<String, String> output) async =>
              validateFields(t, output, existingId: existingId));

  @protected
  Future<Null> validateFields(T t, Map<String, String> output,
      {I existingId: null});
}
