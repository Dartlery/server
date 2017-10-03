import 'dart:async';

import 'package:dartlery_shared/global.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:tools/tools.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:option/option.dart';
import 'package:server/data/data.dart';
import 'package:server/server.dart';
import 'package:server/data_sources/mongo/mongo.dart';
import '../mongo.dart';
import 'mongo_tag_data_source.dart';

class MongoItemDataSource extends AMongoIdDataSource<Item>
    with AItemDataSource {
  static final Logger _log = new Logger('MongoItemDataSource');

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
  static const String inTrashField = "inTrash";
  static const String fullFileAvailableField = "fullFileAvailable";

  final MongoTagDataSource _tagDataSource;

  MongoItemDataSource(MongoDbConnectionPool pool, this._tagDataSource)
      : super(pool);

  @override
  Logger get childLogger => _log;

  @override
  Future<Item> createObject(Map<String, dynamic> data) async {
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
    output.duration = data[durationField];
    output.inTrash = data[inTrashField];
    output.fullFileAvailable = data[fullFileAvailableField];

    if (data[tagsField] != null) {
      output.tags = <Tag>[];

      for (ObjectId id in data[tagsField]) {
        final Option<TagInfo> newTag = await _tagDataSource.getByInternalId(id);
        if (newTag.isEmpty) continue;
        output.tags.add(newTag.first);
      }
    }

    return output;
  }

  Future<Option<SelectorBuilder>> generateVisibleCriteria(
      String userUuid, bool inTrash,
      {SelectorBuilder selector}) async {
    // TODO: Implement filtering for NSFW levels, etc
    if (selector == null) selector = where;
    selector.eq(inTrashField, inTrash);
    return new Some<SelectorBuilder>(
        selector.sortBy(uploadedField, descending: true));
  }

  @override
  Future<PaginatedIdData<Item>> getAllPaginated(
      {int page: 0,
      int perPage: defaultPerPage,
      bool sortDescending: true,
      bool inTrash: false}) async {
    final SelectorBuilder selector = where.eq(inTrashField, inTrash);
    return await getPaginatedListFromDb(selector,
        limit: perPage,
        offset: getOffset(page, perPage),
        sortField: uploadedField,
        sortDescending: sortDescending);
  }

  @override
  MongoCollection get collection => itemsCollection;

  @override
  Future<IdDataList<Item>> getVisible(String userUuid,
      {bool inTrash: false}) async {
    return (await generateVisibleCriteria(userUuid, inTrash)).cata(
        () => new IdDataList<Item>(),
        (SelectorBuilder selector) async => await getListFromDb(selector));
  }

  @override
  Future<PaginatedIdData<Item>> getVisiblePaginated(String userUuid,
      {int page: 0,
      int perPage: defaultPerPage,
      DateTime cutoffDate,
      bool inTrash: false}) async {
    final SelectorBuilder selector = where;
    if (cutoffDate != null) selector.gte(uploadedField, cutoffDate);
    return (await generateVisibleCriteria(userUuid, inTrash,
            selector: selector))
        .cata(() => new PaginatedIdData<Item>(),
            (SelectorBuilder selector) async {
      return await getPaginatedListFromDb(selector,
          limit: perPage, offset: getOffset(page, perPage));
    });
  }

  @override
  Future<int> replaceTags(List<Tag> originalTags, List<Tag> newTags) async {
    if (originalTags == null || originalTags.length == 0)
      throw new ArgumentError.notNull("originalTags");

    final TagDiff diff = new TagDiff(originalTags, newTags);

    final int count = await genericCount(_createTagCriteria(originalTags));

    final List<Tag> tagsToAdd = diff.onlySecond;
    final List<Tag> tagsToRemove = diff.onlyFirst;

    final SelectorBuilder tagSelector = _createTagCriteria(originalTags);

    if (tagsToAdd.length > 0) {
      final ModifierBuilder modifier =
          modify.addToSet(tagsField, {$each: extractTagIds(tagsToAdd)});
      await genericUpdate(tagSelector, modifier, multiUpdate: true);
    }

    if (tagsToRemove.length > 0) {
      final ModifierBuilder modifier =
          modify.pullAll(tagsField, extractTagIds(tagsToRemove));
      await genericUpdate(tagSelector, modifier, multiUpdate: true);
    }

    return count;
  }

  @override
  Future<IdDataList<Item>> searchVisible(String userUuid, String query,
      {bool inTrash: false}) async {
    return (await generateVisibleCriteria(userUuid, inTrash)).cata(
        () => new IdDataList<Item>(),
        (SelectorBuilder selector) async =>
            await search(query, selector: selector));
  }

  @override
  Future<List<Item>> getVisibleRandom(String userUuid,
      {List<Tag> filterTags,
      int perPage: defaultPerRandomPage,
      bool inTrash: false,
      bool imagesOnly: false}) async {
    final List<Map> matchers = [
      {inTrashField: inTrash}
    ];

    if (filterTags != null) {
      final List tagIds =
          new List.from(filterTags.map((Tag t) => t.internalId));
      matchers.add({
        tagsField: {$all: tagIds}
      });
    }
    if (imagesOnly) {
      matchers.add({videoField: false});
      matchers.add({
        mimeField: {$in: MimeTypes.imageTypes}
      });
    }

    return await collectionWrapper<List<Item>>((DbCollection col) async {
      final List pipeline = [
        {
          $match: {$and: matchers}
        },
        {
          $sample: {"size": perPage}
        }
      ];
      final Stream<Map> str = col.aggregateToStream(pipeline);
      return await (await streamToObject(str)).toList();
    });
  }

  @override
  Future<PaginatedIdData<Item>> searchVisiblePaginated(
      String userUuid, List<Tag> tags,
      {int page: 0,
      int perPage: defaultPerPage,
      DateTime cutoffDate,
      bool inTrash: false}) async {
    final SelectorBuilder selector = _createTagCriteria(tags);
    if (cutoffDate != null) selector.gte(uploadedField, cutoffDate);

    return (await generateVisibleCriteria(userUuid, inTrash,
            selector: selector))
        .cata(
            () => new PaginatedIdData<Item>(),
            (SelectorBuilder selector) async => await getPaginatedListFromDb(
                selector,
                limit: perPage,
                offset: getOffset(page, perPage)));
  }

  @override
  Future<Null> setTrashStatus(String id, bool inTrash) async {
    final ModifierBuilder modifier = modify.set(inTrashField, inTrash);
    await genericUpdate(where.eq(idField, id), modifier);
  }

  @override
  Future<Stream<Item>> streamAll(
      {bool addedDesc: true,
      DateTime startDate,
      int limit: defaultPerPage}) async {
    final SelectorBuilder select = where;
    if (startDate != null) {
      if (addedDesc) {
        select.lt(uploadedField, startDate);
      } else {
        select.gt(uploadedField, startDate);
      }
    }
    select.sortBy(uploadedField, descending: addedDesc).limit(limit);

    return await streamFromDb(select);
  }

  @override
  Future<Stream<Item>> streamByMimeType(String mimeType) async {
    return await streamFromDb(
        where.eq(mimeField, mimeType).sortBy(uploadedField, descending: false));
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
    data[inTrashField] = item.inTrash;
    data[durationField] = item.duration;

    if (item.tags != null) {
      final List<dynamic> tagsList = new List<dynamic>();
      for (Tag tag in item.tags) {
        if (tag.internalId == null) {
          throw new Exception("Internal ID for tag not found");
        }
        tagsList.add(tag.internalId);
      }
      data[tagsField] = tagsList;
    }
  }

  @override
  Future<Null> updateTags(String id, List<Tag> tags) async {
    final List<dynamic> tagsList = extractTagIds(tags);
    final ModifierBuilder modifier = modify.set(tagsField, tagsList);
    await genericUpdate(where.eq(idField, id), modifier);
  }

  List<dynamic> extractTagIds(List<Tag> tags) =>
      new List<dynamic>.from(tags.map((Tag t) {
        if (t.internalId == null) throw new Exception("Internal ID not found");
        return t.internalId;
      }));

  SelectorBuilder _createTagCriteria(List<Tag> tags) {
    final SelectorBuilder output = where;

    output.all(tagsField, extractTagIds(tags));

    return output;
  }
}
