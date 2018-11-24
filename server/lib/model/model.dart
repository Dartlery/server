import 'package:dartlery_shared/tools.dart';
import 'package:dice/dice.dart';
import 'src/user_model.dart';
import 'src/setup_model.dart';
//import 'src/settings_model.dart';
import 'src/tag_model.dart';
import 'src/tag_category_model.dart';
import 'src/item_model.dart';
import 'src/import_model.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/extensions/extensions.dart';
import 'src/extension_data_model.dart';

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
import 'package:dartlery/services/extension_service.dart';
import 'package:dartlery/services/background_service.dart';
import '../src/database_info.dart';
export 'src/extension_data_model.dart';

<<<<<<< HEAD
class ModelModule extends Module {
  @override
  void configure() {
    register(UserModel).asSingleton();
    register(ItemModel).asSingleton();
    register(TagModel).asSingleton();
    register(TagCategoryModel).asSingleton();
    register(ImportModel).asSingleton();
    register(SetupModel).asSingleton();
    register(BackgroundService).asSingleton();
    register(ExtensionDataModel).asSingleton();
    register(ExtensionService).asSingleton();
  }
=======
ModuleInjector createModelModuleInjector(DatabaseInfo dbInfo,
    {ModuleInjector parent}) {
  final Module module = new Module()
    ..bind(UserModel)
    ..bind(ItemModel)
    ..bind(TagModel)
    ..bind(TagCategoryModel)
    ..bind(ImportModel)
    ..bind(SetupModel)
    ..bind(BackgroundService)
    ..bind(ExtensionDataModel)
    ..bind(ExtensionService);

  final ModuleInjector parent =
      createDataSourceModuleInjector(dbInfo);
  final ModuleInjector injector = new ModuleInjector([module], parent);

  instantiateExtensions(injector);

  return injector;
>>>>>>> master
}
