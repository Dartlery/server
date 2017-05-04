import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:meta/meta.dart';
import 'package:option/option.dart';

import 'a_typed_model.dart';

abstract class AIdBasedModel<T extends AIdData> extends ATypedModel<T> {
  AIdBasedModel(AUserDataSource userDataSource) : super(userDataSource);

  AIdBasedDataSource<T> get dataSource;

  Future<String> create(T t, {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication)
      await validateCreatePrivileges();
    await validate(t);
    return await dataSource.create(t);
  }

  @override
  Future<Null> validateFields(T t, Map<String, String> output,
      {String existingId: null}) async {
    if(StringTools.isNullOrWhitespace(t.id)) {
      output["id"] = "Required";
    }


    if(StringTools.isNotNullOrWhitespace(existingId)||existingId!=t.id) {
      final bool result = await this.dataSource.existsById(existingId);
      if(result) {
        output["id"] = "Already in use";
      }
    }

  }


  String createID(String input) => generateUuid();

  Future<String> delete(String id) async {
    await validateDeletePrivileges(id);
    await dataSource.deleteById(id);
    return id;
  }

  Future<IdDataList<T>> getAll() async {
    await validateGetAllPrivileges();

    final List<T> output = await dataSource.getAll();
    for (T t in output) await performAdjustments(t);
    return output;
  }

  Future<T> getById(String id, {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication)
      await validateGetByIdPrivileges();
    final Option<T> output = await dataSource.getById(id);
    if (output.isEmpty)
      throw new NotFoundException(
          "ID '$id' not found (${this.runtimeType.toString()})");
    await performAdjustments(output.get());
    return output.get();
  }

  @protected
  Future<Null> performAdjustments(T t) async {}

  Future<IdDataList<T>> search(String query) async {
    await validateSearchPrivileges();
    return await dataSource.search(query);
  }

  Future<String> update(String id, T t,
      {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateUpdatePrivileges(id);

    await validate(t, existingId: id);
    return await dataSource.update(id, t);
  }

  @protected
  Future<Null> validateFieldsInternal(Map<String, String> fieldErrors, T t,
      {String existingId: null}) async {}

  @protected
  Future<Null> validateGetAllPrivileges() async {
    await validateGetPrivileges();
  }

  @protected
  Future<Null> validateGetByIdPrivileges() async {
    await validateGetPrivileges();
  }

  @protected
  Future<Null> validateSearchPrivileges() async {
    await validateGetPrivileges();
  }
}
