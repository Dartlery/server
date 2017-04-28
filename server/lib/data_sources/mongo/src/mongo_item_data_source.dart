import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';
import 'a_mongo_id_data_source.dart';
import 'constants.dart';
import 'mongo_tag_data_source.dart';


class MongoItemDataSource extends AMongoIdDataSource<Item>
    with AItemDataSource {
  static final Logger _log = new Logger('MongoItemDataSource');

  MongoItemDataSource(MongoDbConnectionPool pool): super(pool);

  Future<Option<SelectorBuilder>> generateVisibleCriteria(
      String userUuid) async {
    // TODO: Implement filtering for NSFW levels, etc
    return new Some<SelectorBuilder>(where);
  }

  @override
  Future<IdDataList<Item>> getVisible(String userUuid) async {
    return (await generateVisibleCriteria(userUuid)).cata(
        () => new IdDataList<Item>(),
        (SelectorBuilder selector) async => await getListFromDb(selector));
  }

  @override
  Future<PaginatedIdData<Item>> getVisiblePaginated(String userUuid,
      {int page: 0, int perPage: defaultPerPage}) async {
    return (await generateVisibleCriteria(userUuid)).cata(
        () => new PaginatedIdData<Item>(),
        (SelectorBuilder selector) async => await getPaginatedListFromDb(
            selector,
            limit: perPage,
            offset: getOffset(page, perPage)));
  }

  @override
  Future<PaginatedIdData<Item>> searchVisiblePaginated(
      String userUuid, String query,
      {int page: 0, int perPage: defaultPerPage}) async {
    return (await generateVisibleCriteria(userUuid)).cata(
        () => new PaginatedIdData<Item>(),
        (SelectorBuilder selector) async => await searchPaginated(query,
            selector: selector,
            limit: perPage,
            offset: getOffset(page, perPage)));
  }

  @override
  Future<IdDataList<Item>> searchVisible(
      String userUuid, String query) async {
    return (await generateVisibleCriteria(userUuid)).cata(
        () => new IdDataList<Item>(),
        (SelectorBuilder selector) async =>
            await search(query, selector: selector));
  }

  static const String metadataField = "metadata";
  static const String tagsField = "tags";
  static const String fileField = "file";
  static const String fileThumbnailField = "fileThumbnail";

  @override
  Item createObject(Map<String, dynamic> data) {
    final Item output = new Item();
    AMongoIdDataSource.setUuidForData(output, data);
    output.metadata = data[metadataField];
    output.file = data[fileField];
    output.fileThumbnail= data[fileThumbnailField];

    if(data[tagsField]!=null) {
      output.tags = <Tag>[];
      for (Map<dynamic,dynamic> tag in data[tagsField]) {
        final Tag newTag = MongoTagDataSource.staticCreateObject(tag);
        output.tags.add(newTag);
      }
    }

    return output;
  }

  @override
  Future<DbCollection> getCollection(MongoDatabase con) =>
      con.getItemsCollection();

  @override
  void updateMap(Item item, Map<String, dynamic> data) {
    super.updateMap(item, data);
    data[metadataField] = item.metadata;
    data[fileField] = item.file;
    data[fileThumbnailField] = item.fileThumbnail;
    if(item.tags!=null) {
      final List<dynamic> tagsList = new List<dynamic>();
      for(Tag tag in item.tags) {
        final Map<dynamic,dynamic> tagMap = <dynamic,dynamic>{};
        MongoTagDataSource.staticUpdateMap(tag, tagMap);
        tagsList.add(tagMap);
      }
    data[tagsField] = tagsList;
  }
  }
}
