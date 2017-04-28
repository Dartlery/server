import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:meta/meta.dart';

import 'a_model.dart';

abstract class ATypedModel<T> extends AModel {
  ATypedModel(AUserDataSource userDataSource) : super(userDataSource);

  Future<Null> validate(T t, {String existingId: null}) =>
      DataValidationException.performValidation(
          (Map<String, String> output) async =>
              validateFields(t, output, existingId: existingId));

  @protected
  Future<Null> validateFields(T t, Map<String, String> output,
      {String existingId: null});
}
