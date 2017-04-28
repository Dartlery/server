import 'package:dartlery_shared/tools.dart';
import 'package:di/di.dart';
import 'src/user_model.dart';
import 'src/setup_model.dart';
//import 'src/settings_model.dart';
import 'src/item_model.dart';
import 'package:dartlery/data_sources/data_sources.dart';

export 'src/a_id_based_model.dart';
export 'src/a_file_upload_model.dart';
export 'src/a_model.dart';
export 'src/user_model.dart';
export 'src/setup_model.dart';
//export 'src/settings_model.dart';
export 'src/item_model.dart';

ModuleInjector createModelModuleInjector(String connectionString) {
  final Module module = new Module()
    ..bind(UserModel)
    ..bind(ItemModel)
    ..bind(SetupModel);
//  if (StringTools.isNotNullOrWhitespace(settingsFile)) {
//    output.bind(SettingsModel,
//        toFactory: () => new SettingsModel.openFile(settingsFile));
//  } else {
//    output.bind(SettingsModel);
//  }

  final ModuleInjector parent = createDataSourceModuleInjector(connectionString);
  return new ModuleInjector([module], parent);
}
