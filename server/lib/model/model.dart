import 'package:dartlery_shared/tools.dart';
import 'package:di/di.dart';
import 'src/user_model.dart';
import 'src/setup_model.dart';
//import 'src/settings_model.dart';
import 'src/tag_model.dart';
import 'src/tag_category_model.dart';
import 'src/item_model.dart';
import 'src/import_model.dart';
import 'package:dartlery/data_sources/data_sources.dart';


export 'src/a_id_based_model.dart';
export 'src/a_file_upload_model.dart';
export 'src/a_model.dart';
export 'src/user_model.dart';
export 'src/setup_model.dart';
//export 'src/settings_model.dart';
export 'src/item_model.dart';
export 'src/tag_model.dart';
export 'src/tag_category_model.dart';
export 'src/import_model.dart';

ModuleInjector createModelModuleInjector(String connectionString) {
  final Module module = new Module()
    ..bind(UserModel)
    ..bind(ItemModel)
    ..bind(TagModel)
    ..bind(TagCategoryModel)
    ..bind(ImportModel)
    ..bind(SetupModel);

  final ModuleInjector parent = createDataSourceModuleInjector(connectionString);
  return new ModuleInjector([module], parent);
}
