import 'package:di/di.dart';
import 'src/item_comparison_extension.dart';
import 'package:dartlery/services/extension_service.dart';
import 'src/item_reprocess_extension.dart';
import 'src/import_path_extension.dart';
export 'src/a_extension.dart';
export 'src/item_comparison_extension.dart';
export 'src/item_reprocess_extension.dart';
export 'src/import_path_extension.dart';

ModuleInjector instantiateExtensions(ModuleInjector parent) {
  // TODO: Set up dynamic plugin loader

  final Module module = new Module()
    ..bind(ItemComparisonExtension)
    ..bind(ImportPathExtension)
    ..bind(ItemReprocessExtension);
  final ModuleInjector injector = new ModuleInjector([module], parent);

  final ExtensionService service = injector.get(ExtensionService);
  service.addPlugin(injector.get(ItemComparisonExtension));
  service.addPlugin(injector.get(ImportPathExtension));
  service.addPlugin(injector.get(ItemReprocessExtension));
  return injector;
}
