import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'a_mongo_id_data_source.dart';
import 'constants.dart';

class MongoTagDataSource extends AMongoIdDataSource<Tag> with ATagDataSource {
  static final Logger _log = new Logger('MongoTagDataSource');

  static const String categoryField = 'category';

  MongoTagDataSource(MongoDbConnectionPool pool): super(pool);

  @override
  Tag createObject(Map data) {
    return staticCreateObject(data);
  }

  static Tag staticCreateObject(Map data) {
    final Tag output = new Tag();
    AMongoIdDataSource.setUuidForData(output, data);
    output.category = data[categoryField];
    return output;
  }



  @override
  Future<IdDataList<Tag>> getByUuids(List<String> uuids) async {
    _log.info("Getting all tags for UUIDs");

    if (uuids == null) return new IdDataList<Tag>();

    SelectorBuilder query;

    for (String uuid in uuids) {
      final SelectorBuilder sb = where.eq(uuidField, uuid);
      if (query == null) {
        query = sb;
      } else {
        query.or(sb);
      }
    }

    final List results = await getFromDb(query);

    final IdDataList<Tag> output = new IdDataList<Tag>.copy(results);

    output.sortBytList(uuids);

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
    AMongoIdDataSource.staticUpdateMap(tag, data);
    data[categoryField] = tag.category;
  }
}
