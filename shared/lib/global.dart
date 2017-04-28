import 'tools.dart';
export 'src/exceptions/forbidden_exception.dart';
export 'src/exceptions/invalid_input_exception.dart';
export 'src/exceptions/not_found_exception.dart';
export 'src/exceptions/validation_exception.dart';
export 'src/exceptions/not_implemented_exception.dart';
export 'src/exceptions/unauthorized_exception.dart';
export 'src/item_action.dart';
export 'src/item_status.dart';
export 'src/user_privilege.dart';

const String appName = "Dartlery";
const String galleryApiVersion = "0.1";
const String galleryApiName = "gallery";
const String galleryApiPath = "api/$galleryApiName/$galleryApiVersion/";

const int defaultPerPage = 60;

const String hostedFilesOriginalsPath = "${hostedFilesPath}originals/";
const String hostedFilesPath = "files/";

const String hostedFilesThumbnailsPath = "${hostedFilesPath}thumbnails/";
const int httpStatusServerNeedsSetup = 555;

const int paginatedDataLimit = 60;

const String numericFieldTypeId = "numeric";
const String stringFieldTypeId = "string";
const String dateFieldTypeId = "date";
const String imageFieldTypeId = "image";
const String hiddenFieldTypeId = "hidden";
const String multiValueStringTypeID = "multiValueString";

final Map<String, String> globalFieldTypes = <String, String>{
  numericFieldTypeId: 'Numeric',
  stringFieldTypeId: 'String',
  dateFieldTypeId: 'Date',
  imageFieldTypeId: 'Image',
  hiddenFieldTypeId: 'Hidden',
  multiValueStringTypeID: "Multi-value String",
};

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
