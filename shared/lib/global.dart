import 'dart:convert';
import 'tools.dart';
export 'src/exceptions/forbidden_exception.dart';
export 'src/exceptions/invalid_input_exception.dart';
export 'src/exceptions/not_found_exception.dart';
export 'src/exceptions/validation_exception.dart';
export 'src/exceptions/not_implemented_exception.dart';
export 'src/exceptions/unauthorized_exception.dart';
export 'src/exceptions/duplicate_item_exception.dart';
export 'src/user_privilege.dart';
export 'src/mime_types.dart';
import 'package:path/path.dart' as path;

const String appName = "Dartlery";
const String galleryApiVersion = "v0.1";
const String galleryApiName = "gallery";
const String galleryApiPath = "api/$galleryApiName/$galleryApiVersion/";

const int defaultPerPage = 60;
const int defaultPerRandomPage = 1;

const String hostedFilesPath = "files";

const String fullFileFolderName = "full";
const String thumbnailFileFolderName = "thumbnails";
const String originalFileFolderName = "original";

final String hostedFilesFullPath =
    path.join(hostedFilesPath, fullFileFolderName);
final String hostedFilesThumbnailsPath =
    path.join(hostedFilesPath, thumbnailFileFolderName);
final String hostedFilesOriginalPath =
    path.join(hostedFilesPath, originalFileFolderName);
const int httpStatusServerNeedsSetup = 555;

const int paginatedDataLimit = 60;

const String categoryDeliminator = ";";
const String tagDeliminator = "|";

const String numericFieldTypeId = "numeric";
const String stringFieldTypeId = "string";
const String dateFieldTypeId = "date";
const String imageFieldTypeId = "image";
const String hiddenFieldTypeId = "hidden";
const String multiValueStringTypeID = "multiValueString";

const String apiPrefix = 'api';
const String feedApiName = "feeds";
const String feedApiVersion = "1";

final Map<String, String> globalFieldTypes = <String, String>{
  numericFieldTypeId: 'Numeric',
  stringFieldTypeId: 'String',
  dateFieldTypeId: 'Date',
  imageFieldTypeId: 'Image',
  hiddenFieldTypeId: 'Hidden',
  multiValueStringTypeID: "Multi-value String",
};

abstract class HttpMethod {
  static const String post = "POST";
  static const String get = "GET";
  static const String delete = "DELETE";
  static const String put = "PUT";
  static const String patch = "PATCH";
}

final List<String> _reservedWords = <String>[
  'id',
  'name',
  'title',
  'search',
  'edit',
  'add',
  'test',
];

bool isReservedWord(String input) =>
    _reservedWords.contains(input.trim().toLowerCase());

List<T> createTagListFromJson<T>(String json, T createTag(String id, String category)) {
  final List<T> output = <T>[];
  final JsonDecoder decode = new JsonDecoder();
  final dynamic data = decode.convert(json);
  if (!(data is List)) {
    throw new ArgumentError.value(json, "json", "JSON list expected");
  }
  final List tagData = data;
  for (dynamic subData in tagData) {
    if (!(subData is Map)) {
      throw new ArgumentError.value(
          json, "json", "Non-map entry in list encountered");
    }
    final Map tagSubData = subData;
    String id = tagSubData["id"];
    String category;
    if (tagSubData.containsKey("category")) {
      category = tagSubData["category"];
    }
    output.add(createTag(id, category));
  }
  return  output;
}

String tagListToJson(Iterable<dynamic> tagList) {
  final List<Map<String, String>> output = new List<Map<String, String>>();

  for (dynamic tag in tagList) {
    final Map<String, String> tagMap = <String, String>{};
    tagMap["id"] = tag.id;
    if (tag.hasCategory) {
      tagMap["category"] = tag.category;
    }
    output.add(tagMap);
  }

  final String outputJson = new JsonEncoder().convert(output);
  return outputJson;
}
//class Guid {
//  List<int> data;
//
//  Guid(this.data);
//
//  @override
//  String toString() {
//    return formatUuid(this.data.map<String>((int i) => i.toRadixString(16)).join());
//  }
//}
