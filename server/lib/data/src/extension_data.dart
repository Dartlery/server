import 'package:rpc/rpc.dart';
import 'package:server/data/data.dart';
import 'package:server/data_sources/data_sources.dart';

class ExtensionData extends AData {
  static const String extensionIdField = 'extensionId';
  static const String keyField = "key";
  static const String primaryIdField = "primaryId";
  static const String secondaryIdField = "secondaryId";
  static const String valueField = "value";
  static const String inTrashField = "inTrash";

  static const String extensionDataIndexName = "ExtensionDataIndex";
  static const String extensionDataKeyIndexName = "ExtensionDataKeyIndex";
  static const String extensionDataKeyValueDescendingIndexName = "ExtensionDataKeyValueDescendingIndex";

  @ApiProperty(ignore: true)
  @DbIndex(extensionDataIndexName, order: 0)
  @DbIndex(extensionDataKeyIndexName, order: 0)
  @DbIndex(extensionDataKeyValueDescendingIndexName, order: 0)
  String extensionId;

  @ApiProperty(ignore: true)
  @DbIndex(extensionDataIndexName, order: 1)
  @DbIndex(extensionDataKeyIndexName, order: 1)
  @DbIndex(extensionDataKeyValueDescendingIndexName, order: 1)
  String key;

  @DbIndex(extensionDataIndexName, order: 2)
  String primaryId;

  @DbIndex(extensionDataIndexName, order: 3)
  String secondaryId;

  // TODO: Enforce these data types?
  /// Note: The data types allowed by this type are restricted by what the
  /// underlying database storage supports. Please restrict to these data types
  /// for the best results: [String], [Map], [List], [DateTime], [int], [double]
  @ApiProperty(ignore: true)
  @DbIndex(extensionDataKeyValueDescendingIndexName, order: 2, ascending: false)
  dynamic value;

  @ApiProperty(ignore: false, name: "value")
  String externalValue;
}
