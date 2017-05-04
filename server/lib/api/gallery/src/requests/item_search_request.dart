import 'package:dartlery/data/data.dart';
import 'package:dartlery_shared/global.dart';

class ItemSearchRequest {
  List<Tag> tags = <Tag>[];
  int page = 0;
  int perPage = defaultPerPage;
  DateTime cutoffDate;
}