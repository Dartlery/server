import 'a_id_data.dart';
import 'package:option/option.dart';
import 'tag.dart';
import 'package:rpc/rpc.dart';

@ApiMessage(includeSuper: true)
class Item extends AIdData {
  List<Tag> tags = <Tag>[];

  String mime;
  DateTime uploaded;
  String fileName;
  int length;
  String extension;

  Map<String,String> metadata = <String,String>{};

  List<int> fileData;

  Item();
}
