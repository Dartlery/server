import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:meta/meta.dart';
import 'package:orm/orm.dart';

import 'a_typed_model.dart';

abstract class AIdBasedModel<T extends AIdData,I> extends ATypedModel<T,I> {
  AIdBasedModel(DatabaseContext db) : super(db);


  Future<String> create(T t, {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateCreatePrivileges();
    await validate(t);
    await db.add(t);
    return t.id;
  }

  @override
  Future<Null> validateFields(T t, Map<String, String> output,
      {I existingId: null}) async {
    if (isNullOrWhitespace(t.id)) {
      output["id"] = "Required";
    }

    if (isNotNullOrWhitespace(existingId?.toString()) || existingId != t.id) {
      final bool result = await this.db.existsByCriteria(t.runtimeType, _idCriteria(existingId));
      if (result) {
        output["id"] = "Already in use";
      }
    }
  }

  Criteria _idCriteria(I id) => where..equals(AIdData.idField, id);
  
  String createID(String input) => generateUuid();

  Future<I> delete(I id) async {
    await validateDeletePrivileges(id);
    await db.deleteByCriteria(T, _idCriteria(id));
    return id;
  }

  Future<IdDataList<T>> getAll() async {
    await validateGetAllPrivileges();

    final List<T> output = await db.getAllByQuery(T, select..sort(User.nameField));
    for (T t in output) await performAdjustments(t);
    return output;
  }

  Future<T> getById(I id, {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateGetByIdPrivileges();
    T output;
    try {
      output = await db.getOneByQuery(T, _idCriteria(id));
    } on ItemNotFoundException {
      throw new NotFoundException(
          "ID '$id' not found (${this.runtimeType.toString()})");
    }
    
    await performAdjustments(output);
    return output;
  }

  @protected
  Future<Null> performAdjustments(T t) async {}

  Future<IdDataList<T>> search(String query) async {
    await validateSearchPrivileges();
    return await db.search(User, query);
  }

  Future<String> update(I id, T t,
      {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateUpdatePrivileges(id);

    await validate(t, existingId: id);
    final User dbUser = await db.getOneByQuery(T, where..equals(AIdData.idField, id));
    t.id = dbUser.id;
    t.ormInternalId = dbUser.ormInternalId;
    return await db.update(t);
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
