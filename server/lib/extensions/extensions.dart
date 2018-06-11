import 'package:dice/dice.dart';
import 'src/item_comparison_extension.dart';
import 'package:dartlery/services/extension_service.dart';
import 'src/item_reprocess_extension.dart';
import 'src/import_path_extension.dart';
export 'src/a_extension.dart';
export 'src/item_comparison_extension.dart';
export 'src/item_reprocess_extension.dart';
export 'src/import_path_extension.dart';


class ExtensionsModule extends Module {

  @override
  void configure() {
    register(ItemComparisonExtension).asSingleton();

    register(ImportPathExtension).asSingleton();
    register(ItemReprocessExtension).asSingleton();
  }
}

