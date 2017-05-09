import 'package:di/di.dart';
import 'src/item_comparison_extension.dart';
import 'package:dartlery/services/extension_service.dart';

export 'src/a_extension.dart';
export 'src/item_comparison_extension.dart';


void instantiateExtensions(ModuleInjector parent) {
  // TODO: Set up dynamic plugin loader

  final Module module = new Module()
    ..bind(ItemComparisonExtension);
  final ModuleInjector injector =  new ModuleInjector([module], parent);

  final ExtensionService service = injector.get(ExtensionService);
  service.addPlugin(injector.get(ItemComparisonExtension));
}