import '../../../api.dart';
import 'package:dartlery/data/data.dart';
import 'package:rpc/rpc.dart';

@ApiMessage(includeSuper: true)
class PaginatedTagResponse extends PaginatedResponse<TagInfo> {
  PaginatedTagResponse();

  PaginatedTagResponse.fromPaginatedData(PaginatedData<TagInfo> data)
      : super.fromPaginatedData(data);
}
