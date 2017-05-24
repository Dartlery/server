import 'dart:async';
import 'package:dartlery_shared/tools.dart';
import 'package:option/option.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:dartlery_shared/global.dart';
import 'a_mongo_two_id_data_source.dart';
import 'constants.dart';

class MongoTagDataSource extends AMongoTwoIdDataSource<Tag>
    with ATagDataSource {
  static final Logger _log = new Logger('MongoTagDataSource');

  @override
  Logger get childLogger => _log;

  static const String categoryField = 'category';
  static const String fullNameField = "fullName";
  static const String redirectField = "redirect";

  MongoTagDataSource(MongoDbConnectionPool pool) : super(pool);

  @override
  String get secondIdField => categoryField;

  @override
  Tag createObject(Map data) {
    return staticCreateObject(data);
  }

  static Tag staticCreateObject(Map data) {
    final Tag output = new Tag();
    AMongoTwoIdDataSource.setIdForData(output, data);
    output.category = data[categoryField];

    if (data[redirectField] != null) {
      output.redirect = staticCreateObject(data[redirectField]);
    }
    return output;
  }

  @override
  Future<IdDataList<Tag>> getByRedirect(String id, String category) async {
    return await getFromDb(where
        .eq("$redirectField.$idField", id)
        .eq("$redirectField.$categoryField", category));
  }

  @override
  Future<Null> deleteByRedirect(String id, String category) async {
    await deleteFromDb(where
        .eq("$redirectField.$idField", id)
        .eq("$redirectField.$categoryField", category));
  }

  @override
  Future<String> update(String id, String category, Tag object) async {
    final String output = await super.update(id, category, object);
    await genericUpdate(where
        .eq("$redirectField.$idField", id)
        .eq("$redirectField.$categoryField", category), modify
        .set("$redirectField.$idField", object.id)
        .set("$redirectField.$categoryField", object.category));
    return output;
  }

  @override
  Future<IdDataList<Tag>> search(String query,
      {SelectorBuilder selector, String sortBy, int limit}) async {
    SelectorBuilder sb;
    if (selector == null)
      sb = where;
    else
      sb = selector;

    sb = sb
        .match(fullNameField, ".*$query.*",
        multiLine: false, caseInsensitive: true, dotAll: true)
        .sortBy(sortBy ?? fullNameField)
        .limit(limit ?? 25);

    return await super.getListFromDb(sb);
  }

  @override
  Future<DbCollection> getCollection(MongoDatabase con) =>
      con.getTagsCollection();

  @override
  void updateMap(Tag tag, Map data) {
    staticUpdateMap(tag, data);
  }

  static void staticUpdateMap(Tag tag, Map data, {bool onlyKeys: false}) {
    AMongoTwoIdDataSource.staticUpdateMap(tag, data);
    if (StringTools.isNullOrWhitespace(tag.category))
      data[categoryField] = null;
    else
      data[categoryField] = tag.category;
    if (!onlyKeys) {
      data[fullNameField] = tag.fullName;

      if (tag.redirect != null) {
        final Map redirect = {};
        staticUpdateMap(tag.redirect, redirect, onlyKeys: true);
        data[redirectField] = redirect;
      }
    }
  }

  static List<Map> createTagsList(List<Tag> tags, {bool onlyKeys: false}) {
    final List<Map> output = <Map>[];
    for (Tag tag in tags) {
      final Map<dynamic, dynamic> tagMap = <dynamic, dynamic>{};
      MongoTagDataSource.staticUpdateMap(tag, tagMap, onlyKeys: onlyKeys);
      output.add(tagMap);
    }
    return output;
  }
}
