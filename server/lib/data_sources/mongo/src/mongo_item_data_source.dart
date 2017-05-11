import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';

import 'a_mongo_id_data_source.dart';
import 'constants.dart';
import 'mongo_tag_data_source.dart';

class MongoItemDataSource extends AMongoIdDataSource<Item>
    with AItemDataSource {
  static final Logger _log = new Logger('MongoItemDataSource');
  @override
  Logger get childLogger => _log;

  static const String metadataField = "metadata";

  static const String tagsField = "tags";

  static const String fileField = "file";

  static const String mimeField = "mime";

  static const String uploadedField = "uploaded";
  static const String uploaderField = "uploader";

  static const String fileNameField = "fileName";

  static const String lengthField = "length";
  static const String errorsField = "errors";
  static const String extensionField = "extension";
  static const String sourceField = "source";
  static const String heightField = "height";
  static const String widthField = "width";
  static const String videoField = "video";
  static const String audioField = "audio";
  static const String durationField = "duration";
  static const String fullFileAvailableField = "fullFileAvailable";
  MongoItemDataSource(MongoDbConnectionPool pool) : super(pool);
  @override
  Item createObject(Map<String, dynamic> data) {
    final Item output = new Item();
    AMongoIdDataSource.setIdForData(output, data);
    output.metadata = data[metadataField];
    output.uploaded = data[uploadedField];
    output.uploader = data[uploaderField];
    output.mime = data[mimeField];
    output.fileName = data[fileNameField];
    output.length = data[lengthField];
    output.extension = data[extensionField];
    output.source = data[sourceField];
    output.errors = data[errorsField];
    output.height = data[heightField];
    output.width = data[widthField];
    output.video = data[videoField];
    output.audio = data[audioField];
    output.duration= data[durationField];
    output.fullFileAvailable= data[fullFileAvailableField];

    if (data[tagsField] != null) {
      output.tags = <Tag>[];
      for (Map<dynamic, dynamic> tag in data[tagsField]) {
        final Tag newTag = MongoTagDataSource.staticCreateObject(tag);
        output.tags.add(newTag);
      }
    }


    return output;
  }

  Future<Option<SelectorBuilder>> generateVisibleCriteria(String userUuid,
      {SelectorBuilder selector}) async {
    // TODO: Implement filtering for NSFW levels, etc
    if (selector == null) selector = where;
    return new Some<SelectorBuilder>(
        selector.sortBy(uploadedField, descending: true));
  }

  @override
  Future<PaginatedIdData<Item>> getAllPaginated(
      {int page: 0, int perPage: defaultPerPage, bool sortDescending: true}) async {
    final SelectorBuilder selector = where;
    return await getPaginatedListFromDb(selector,
        limit: perPage,
        offset: getOffset(page, perPage),
        sortField: uploadedField,
        sortDescending: sortDescending);
  }

  @override
  Future<Stream<Item>> streamAll() async {
    return await streamFromDb(where.sortBy(uploadedField, descending: false));
  }


  @override
  Future<Stream<Item>> streamByMimeType(String mimeType) async {
    return await streamFromDb(where.eq(mimeField, mimeType).sortBy(uploadedField, descending: false));
  }
  @override
  Future<DbCollection> getCollection(MongoDatabase con) =>
      con.getItemsCollection();

  @override
  Future<IdDataList<Item>> getVisible(String userUuid) async {
    return (await generateVisibleCriteria(userUuid)).cata(
        () => new IdDataList<Item>(),
        (SelectorBuilder selector) async => await getListFromDb(selector));
  }

  @override
  Future<PaginatedIdData<Item>> getVisiblePaginated(String userUuid,
      {int page: 0, int perPage: defaultPerPage, DateTime cutoffDate}) async {
    final SelectorBuilder selector = where;
    if (cutoffDate != null) selector.gte(uploadedField, cutoffDate);
    return (await generateVisibleCriteria(userUuid, selector: selector)).cata(
        () => new PaginatedIdData<Item>(), (SelectorBuilder selector) async {
      return await getPaginatedListFromDb(selector,
          limit: perPage, offset: getOffset(page, perPage));
    });
  }

  @override
  Future<IdDataList<Item>> searchVisible(String userUuid, String query) async {
    return (await generateVisibleCriteria(userUuid)).cata(
        () => new IdDataList<Item>(),
        (SelectorBuilder selector) async =>
            await search(query, selector: selector));
  }

  @override
  Future<PaginatedIdData<Item>> searchVisiblePaginated(
      String userUuid, List<Tag> tags,
      {int page: 0, int perPage: defaultPerPage, DateTime cutoffDate}) async {
    final SelectorBuilder selector = where;
    if (cutoffDate != null) selector.gte(uploadedField, cutoffDate);

    tags.forEach((Tag t) {
      String category;
      if (StringTools.isNotNullOrWhitespace(t.category)) category = t.category;
      selector.eq("tags", {
        "\$elemMatch": {"id": t.id, "category": category}
      });
    });

    return (await generateVisibleCriteria(userUuid, selector: selector)).cata(
        () => new PaginatedIdData<Item>(),
        (SelectorBuilder selector) async => await getPaginatedListFromDb(
            selector,
            limit: perPage,
            offset: getOffset(page, perPage)));
  }



  @override
  void updateMap(Item item, Map<String, dynamic> data) {
    super.updateMap(item, data);
    data[metadataField] = item.metadata;
    data[mimeField] = item.mime;
    data[uploadedField] = item.uploaded;
    data[uploaderField] = item.uploader;
    data[fileNameField] = item.fileName;
    data[lengthField] = item.length;
    data[extensionField] = item.extension;
    data[sourceField] = item.source;
    data[errorsField] = item.errors;
    data[fullFileAvailableField] = item.fullFileAvailable;

    data[heightField] = item.height;
    data[widthField] = item.width;
    data[videoField] = item.video;
    data[audioField] = item.audio;
    data[durationField] = item.duration;

    if (item.tags != null) {
      final List<dynamic> tagsList = new List<dynamic>();
      for (Tag tag in item.tags) {
        final Map<dynamic, dynamic> tagMap = <dynamic, dynamic>{};
        MongoTagDataSource.staticUpdateMap(tag, tagMap);
        tagsList.add(tagMap);
      }
      data[tagsField] = tagsList;
    }
  }

  @override
  Future<Null> updateTags(String id, List<Tag> tags) async {
    final List<dynamic> tagsList = new List<dynamic>();
    for (Tag tag in tags) {
      final Map<dynamic, dynamic> tagMap = <dynamic, dynamic>{};
      MongoTagDataSource.staticUpdateMap(tag, tagMap);
      tagsList.add(tagMap);
    }
    final ModifierBuilder modifier = modify.set(tagsField, tagsList);
    await genericUpdate(where.eq(idField, id), modifier);
  }
}
