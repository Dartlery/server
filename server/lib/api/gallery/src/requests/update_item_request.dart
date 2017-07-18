import 'package:dartlery/data/data.dart';
import 'package:rpc/rpc.dart';

class UpdateItemRequest {
  Item item;
  List<MediaMessage> files = new List<MediaMessage>();

  UpdateItemRequest();
}
