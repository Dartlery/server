import 'package:option/option.dart';
import 'package:rpc/rpc.dart';

import 'a_id_data.dart';
import 'tag.dart';

@ApiMessage(includeSuper: true)
class Item extends AIdData {
  String extension;
  List<int> fileData;
  String fileName;
  String downloadName;
  int length;
  int height;
  int width;
  int duration;
  bool video = false;
  bool audio = false;
  Map<String, String> metadata = <String, String>{};
  String mime;
  String source;
  List<Tag> tags = <Tag>[];
  DateTime uploaded;
  String uploader;
  List<String> errors = <String>[];
  bool fullFileAvailable = false;

  @ApiProperty(ignore: true)
  bool inTrash = false;

  Item();
}
