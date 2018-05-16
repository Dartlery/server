import '../../../api.dart';
import 'package:dartlery/data/data.dart';
import 'package:rpc/rpc.dart';

@ApiMessage(includeSuper: true)
class PaginatedItemResponse extends PaginatedResponse<String> {
  PaginatedItemResponse();

  List<Tag> queryTags;

  PaginatedItemResponse.fromPaginatedData(PaginatedData<String> data)
      : super.fromPaginatedData(data);

  PaginatedItemResponse.convertPaginatedData(
      PaginatedData data, String conversion(dynamic item))
      : super.convertPaginatedData(data, conversion);
}
