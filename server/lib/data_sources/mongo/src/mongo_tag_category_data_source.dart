import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'a_mongo_id_data_source.dart';
import 'constants.dart';

class MongoTagCategoryDataSource extends AMongoIdDataSource<TagCategory> with ATagCategoryDataSource {
  static final Logger _log = new Logger('MongoTagCategoryDataSource');
  @override
  Logger get childLogger => _log;


static const String colorField = "color";

  MongoTagCategoryDataSource(MongoDbConnectionPool pool): super(pool);

  @override
  TagCategory createObject(Map data) {
    return staticCreateObject(data);
  }

  static TagCategory staticCreateObject(Map data) {
    final TagCategory output = new TagCategory();
    AMongoIdDataSource.setIdForData(output, data);
    output.color = data[colorField];
    return output;
  }


  @override
  Future<DbCollection> getCollection(MongoDatabase con) =>
      con.getTagCategoriesCollection();

  @override
  void updateMap(TagCategory tag, Map data) {
    super.updateMap(tag, data);
    data[colorField] = tag.color;
  }
}
