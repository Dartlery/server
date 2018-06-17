import 'package:dartlery/data/src/a_id_data.dart';
import 'package:dartlery/data/src/id_list.dart';

import 'paginated_data.dart';

class PaginatedIdData<T extends AIdData> extends PaginatedData<T> {
  final IdDataList<T> _data;

  PaginatedIdData() : _data = new IdDataList<T>();

  PaginatedIdData.copyPaginatedData(PaginatedData<T> data)
      : this._data = new IdDataList<T>.copy(data.data) {
    this.totalCount = data.totalCount;
    this.limit = data.limit;
    this.startIndex = data.startIndex;
  }

  @override
  IdDataList<T> get data => _data;
}
