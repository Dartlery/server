import 'package:rpc/rpc.dart';
import 'a_data.dart';
class ExtensionData extends AData {
  @ApiProperty(ignore: true)
  String extensionId;
  @ApiProperty(ignore: true)
  String key;
  String primaryId;
  String secondaryId;

  // TODO: Enforce these data types?
  /// Note: The data types allowed by this type are restricted by what the
  /// underlying database storage supports. Please restrict to these data types
  /// for the best results: [String], [Map], [List], [DateTime], [int], [double]
  @ApiProperty(ignore: true)
  dynamic value;

  @ApiProperty(ignore: false, name: "value")
  String externalValue;
}