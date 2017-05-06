import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:dartlery_shared/global.dart';
import 'a_mongo_two_id_data_source.dart';
import 'constants.dart';

class MongoTagDataSource extends AMongoTwoIdDataSource<Tag> with ATagDataSource {
  static final Logger _log = new Logger('MongoTagDataSource');
  @override
  Logger get childLogger => _log;

  static const String categoryField = 'category';
  static const String fullNameField = "fullName";

  MongoTagDataSource(MongoDbConnectionPool pool): super(pool);

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
    return output;
  }

  @override
  Future<IdDataList<Tag>> search(String query,
      {SelectorBuilder selector, String sortBy, int limit}) async {
    SelectorBuilder sb;
    if(selector==null)
      sb = where;
    else
      sb = selector;

     sb = sb.match(fullNameField, ".*$query.*", multiLine: false, caseInsensitive: true, dotAll: true).sortBy(sortBy??fullNameField).limit(limit??25);

    return await super.getListFromDb(sb);
  }


  @override
  Future<IdDataList<Tag>> getByIds(List<String> ids) async {
    _log.info("Getting all tags for IDs");

    if (ids == null) return new IdDataList<Tag>();

    SelectorBuilder query;

    for (String uuid in ids) {
      final SelectorBuilder sb = where.eq(idField, uuid);
      if (query == null) {
        query = sb;
      } else {
        query.or(sb);
      }
    }

    final List results = await getFromDb(query);

    final IdDataList<Tag> output = new IdDataList<Tag>.copy(results);

    output.sortBytList(ids);

    return output;
  }

  @override
  Future<DbCollection> getCollection(MongoDatabase con) =>
      con.getTagsCollection();

  @override
  void updateMap(Tag tag, Map data) {
    staticUpdateMap(tag, data);
  }

  static void staticUpdateMap(Tag tag, Map data) {
    AMongoTwoIdDataSource.staticUpdateMap(tag, data);
    data[categoryField] = tag.category;
    data[fullNameField] = tag.fullName;
  }
}
