import '../../../api.dart';
import 'package:dartlery/data/data.dart';
import 'package:rpc/rpc.dart';

@ApiMessage(includeSuper: true)
class PaginatedExtensionDataResponse extends PaginatedResponse<ExtensionData> {

  PaginatedExtensionDataResponse();

  PaginatedExtensionDataResponse.fromPaginatedData(PaginatedData<ExtensionData> data): super.fromPaginatedData(data);
}