import 'package:dartlery/data/data.dart';
import 'package:rpc/rpc.dart';

class CreateItemRequest {
  Item item;
  List<MediaMessage> files = new List<MediaMessage>();

  CreateItemRequest();
}
