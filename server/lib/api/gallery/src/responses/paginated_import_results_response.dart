import '../../../api.dart';
import 'package:dartlery/data/data.dart';
import 'package:rpc/rpc.dart';

@ApiMessage(includeSuper: true)
class PaginatedImportResultsResponse extends PaginatedResponse<ImportResult> {
  PaginatedImportResultsResponse();

  PaginatedImportResultsResponse.fromPaginatedData(
      PaginatedData<ImportResult> data)
      : super.fromPaginatedData(data);
}
