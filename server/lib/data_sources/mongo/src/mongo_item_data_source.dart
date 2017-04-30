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
import 'package:dartlery_shared/tools.dart';


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
      String userUuid, List<Tag> tags,
      {int page: 0, int perPage: defaultPerPage}) async {

    final SelectorBuilder query = where;

    tags.forEach((Tag t) {
      String category;
      if(StringTools.isNotNullOrWhitespace(t.category))
        category= t.category;
      query.eq("tags", {"\$elemMatch": { "id": t.id, "category": category }});
    });


    return (await generateVisibleCriteria(userUuid)).cata(
        () => new PaginatedIdData<Item>(),
        (SelectorBuilder selector) async =>
        await getPaginatedListFromDb(query,
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

  @override
  Item createObject(Map<String, dynamic> data) {
    final Item output = new Item();
    AMongoIdDataSource.setIdForData(output, data);
    output.metadata = data[metadataField];

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
