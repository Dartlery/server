import 'package:orm/orm.dart';

import 'package:rpc/rpc.dart';

class AIdData extends OrmObject {
  @override
  @ApiProperty(ignore: true)
  dynamic get ormInternalId;

  @DbField()
  String id = "";

  AIdData();

  AIdData.withValues(this.id);

  AIdData.copy(dynamic o) {
    this.id = o.id;
  }
}
