import 'package:option/option.dart';
import 'package:rpc/rpc.dart';

import 'a_id_data.dart';
import 'tag.dart';

@ApiMessage(includeSuper: true)
class Item extends AIdData {
  String extension;
  List<int> fileData;
  String fileName;
  int length;
  Map<String, String> metadata = <String, String>{};
  String mime;
  String source;
  List<Tag> tags = <Tag>[];
  DateTime uploaded;
  String uploader;

  @ApiProperty(ignore: true)
  Map<String,dynamic> pluginData = <String, dynamic>{};

  Item();
}
