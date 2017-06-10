import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';

import 'a_mongo_two_id_data_source.dart';
import 'constants.dart';

class MongoTagDataSource extends AMongoTwoIdDataSource<TagInfo>
    with ATagDataSource {
  static final Logger _log = new Logger('MongoTagDataSource');

  static const String categoryField = 'category';

  static const String fullNameField = "fullName";
  static const String redirectField = "redirect";
  static const String countField = "count";
  MongoTagDataSource(MongoDbConnectionPool pool) : super(pool);

  @override
  Logger get childLogger => _log;

  @override
  String get secondIdField => categoryField;

  @override
  Future<Null> cleanUpTags() async {
    await databaseWrapper((MongoDatabase con) async {
      final DbCollection itemsCol = await con.getItemsCollection();
      final DbCollection tagCol = await con.getTagsCollection();

      await tagCol.update({}, modify.set(countField, 0), multiUpdate: true);

      final Stream<Map> pipe = itemsCol.aggregateToStream([
        {$unwind: "\$tags"},
        {
          $group: {
            internalIdField: "\$tags",
            "count": {$sum: 1}
          }
        }
      ]);
      await for (Map agr in pipe) {
        final Option<TagInfo> t = await getByInternalId(agr[internalIdField]);
        if (t.isEmpty)
          throw new Exception("Item tag missing: ${agr[internalIdField]}");

        await tagCol.update(where.eq(internalIdField, agr[internalIdField]),
            modify.set(countField, agr["count"]),
            multiUpdate: false);
      }

      final SelectorBuilder select =
          where.eq(countField, 0).notExists(redirectField);

      final Stream<ObjectId> tagPipe =
          (await genericFindStream(select)).map((Map m) => m[internalIdField]);
      await for (ObjectId id in tagPipe) {
        if (!(await exists(where.eq(redirectField, id)))) {
          await tagCol.remove(select);
        }
      }
    });
  }

  @override
  Future<int> countTagUse(Tag t) async {
    return databaseWrapper<int>((MongoDatabase con) async {
      if (t.internalId == null) throw new Exception("Tag internal ID missing");
      final DbCollection itemsCol = await con.getItemsCollection();
      return await itemsCol.count(where.eq("tags", t.internalId));
    });
  }

  @override
  Future<TagInfo> createObject(Map data) async {
    final TagInfo output = new TagInfo();

    if (data[redirectField] != null) {
      final Option<TagInfo> redirect =
          await getByInternalId(data[redirectField]);
      if (redirect.isEmpty)
        throw new Exception("Redirect tag target not found");

      output.redirect = redirect.first;
    }

    AMongoTwoIdDataSource.setIdForData(output, data);
    output.category = data[categoryField];
    output.count = data[countField] ?? 0;
    output.internalId = data[internalIdField];
    return output;
  }

  @override
  Future<Null> deleteByRedirect(String id, String category) async {
    await deleteFromDb(where
        .eq("$redirectField.$idField", id)
        .eq("$redirectField.$categoryField", category));
  }

  @override
  Future<PaginatedData<TagInfo>> getAllPaginated(
      {int page: 0, int perPage: defaultPerPage, bool countAsc: null}) async {
    final SelectorBuilder sb = where;
    if (countAsc != null) sb.sortBy(countField, descending: !countAsc);
    return await getPaginatedFromDb(sb,
        offset: getOffset(page, perPage), limit: perPage);
  }

  @override
  Future<Option<TagInfo>> getById(String id, String category) async {
    final SelectorBuilder select = _createTagCriteria(id, category);
    return getForOneFromDb(select);
  }

  Future<Option<TagInfo>> getByInternalId(ObjectId internalId) async {
    final SelectorBuilder select = where.eq("_id", internalId);
    return getForOneFromDb(select);
  }

//  Future<List<TagInfo>> getByRedirect(String id, String category) async {
//    final SelectorBuilder select =
//        _createTagCriteria(id, category, fieldPrefix: redirectField);
//    return new List<TagInfo>.from(await getFromDb(select));
//  }

  @override
  Future<DbCollection> getCollection(MongoDatabase con) =>
      con.getTagsCollection();

  @override
  Future<List<TagInfo>> getRedirects() async {
    return new List<TagInfo>.from(await getFromDb(where.exists(redirectField)));
  }

  @override
  Future<Null> incrementTagCount(List<Tag> tags, int amount) async {
    if (tags.length == 0) throw new ArgumentError.notNull("tags");
    if (amount == 0) throw new ArgumentError.value(amount, "amount");

    final SelectorBuilder select =
        where.eq(internalIdField, tags[0].internalId);
    for (int i = 1; i < tags.length; i++) {
      select.or(where.eq(internalIdField, tags[i].internalId));
    }

    final ModifierBuilder modifier = modify.inc(countField, amount);

    await genericUpdate(select, modifier, multiUpdate: true);
  }

  @override
  Future<Null> refreshTagCount(List<Tag> tags) async {
    if (tags.length == 0) throw new ArgumentError.notNull("tags");

    for (Tag t in tags) {
      if (t.internalId == null) throw new Exception("Tag internal ID missing");
      final int count = await countTagUse(t);
      final SelectorBuilder select = where.eq(internalIdField, t.internalId);
      await genericUpdate(select, modify.set(countField, count),
          multiUpdate: false);
    }
  }

  @override
  Future<IdDataList<TagInfo>> search(String query,
      {SelectorBuilder selector,
      String sortBy,
      int limit: defaultPerPage,
      bool countAsc: true}) async {
    SelectorBuilder sb;
    if (selector == null)
      sb = where;
    else
      sb = selector;

    sb.match(fullNameField, ".*${escapeAll(query)}.*",
        multiLine: false, caseInsensitive: true);

    if (countAsc != null) sb.sortBy(countField, descending: !countAsc);

    sb.sortBy(sortBy ?? fullNameField).limit(limit ?? 25);

    return await super.getListFromDb(sb);
  }

  @override
  Future<PaginatedData<TagInfo>> searchPaginated(String query,
      {int page: 0, int perPage: defaultPerPage, bool countAsc: true}) async {
    final SelectorBuilder sb = where.match(
        fullNameField, ".*${escapeAll(query)}.*",
        multiLine: false, caseInsensitive: true);

    if (countAsc != null) sb.sortBy(countField, descending: !countAsc);

    sb.sortBy(fullNameField);

    return await getPaginatedFromDb(sb,
        limit: perPage, offset: getOffset(page, perPage));
  }

  @override
  Future<String> update(String id, String category, Tag object) async {
    final SelectorBuilder select =
        _createTagCriteria(id, category, fieldPrefix: redirectField);
    final String output = await super.update(id, category, object);
    await genericUpdate(
        select,
        modify
            .set("$redirectField.$idField", object.id)
            .set("$redirectField.$categoryField", object.category));
    return output;
  }

  @override
  void updateMap(TagInfo tag, Map data) {
    AMongoTwoIdDataSource.staticUpdateMap(tag, data);
    if (StringTools.isNullOrWhitespace(tag.category))
      data[categoryField] = null;
    else
      data[categoryField] = tag.category;

    data[fullNameField] = tag.fullName;

    if (tag is TagInfo && tag.redirect != null) {
      if (tag.redirect.internalId == null)
        throw new Exception("Redirect tag internal ID not found");

      data[redirectField] = tag.redirect.internalId;
    } else if (data.containsKey(redirectField)) {
      data.remove(redirectField);
    }
    // Note: We do not update the tag count, that is only done by increment functions
  }

  SelectorBuilder _createTagCriteria(String id, String category,
      {String fieldPrefix = ""}) {
    if (StringTools.isNotNullOrWhitespace(fieldPrefix))
      fieldPrefix = "$fieldPrefix.";

    final SelectorBuilder select = where.match(
        "$fieldPrefix$idField", "^${escapeAll(id)}\$",
        caseInsensitive: true);

    if (StringTools.isNullOrWhitespace(category)) {
      select.eq("$fieldPrefix$categoryField", null);
    } else {
      select.match("$fieldPrefix$categoryField", "^${escapeAll(category)}\$",
          caseInsensitive: true);
    }

    return select;
  }

//  List<Map> _createTagsList(List<Tag> tags, {bool onlyKeys: false}) {
//    final List<Map> output = <Map>[];
//    for (Tag tag in tags) {
//      final Map<dynamic, dynamic> tagMap = <dynamic, dynamic>{};
//      updateMap(tag, tagMap, onlyKeys: onlyKeys);
//      output.add(tagMap);
//    }
//    return output;
//  }
}
