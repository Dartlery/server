import 'package:dartlery/data/data.dart';
import 'package:dartlery_shared/global.dart';
import 'package:server/server.dart';

class ItemSearchRequest {
  List<Tag> tags = <Tag>[];
  int page = 0;
  int perPage = defaultPerPage;
  DateTime cutoffDate;
  bool inTrash = false;
}
