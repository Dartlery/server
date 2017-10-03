import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../mongo.dart';
import 'package:server/data_sources/mongo/mongo.dart';

class MongoTagCategoryDataSource extends AMongoIdDataSource<TagCategory>
    with ATagCategoryDataSource {
  static final Logger _log = new Logger('MongoTagCategoryDataSource');
  @override
  Logger get childLogger => _log;

  static const String colorField = "color";

  MongoTagCategoryDataSource(MongoDbConnectionPool pool) : super(pool);

  @override
  Future<TagCategory> createObject(Map data) async {
    return staticCreateObject(data);
  }

  static TagCategory staticCreateObject(Map data) {
    final TagCategory output = new TagCategory();
    AMongoIdDataSource.setIdForData(output, data);
    output.color = data[colorField];
    return output;
  }

  @override
  MongoCollection get collection => tagCategoriesCollection;

  @override
  void updateMap(TagCategory tag, Map data) {
    super.updateMap(tag, data);
    data[colorField] = tag.color;
  }
}
