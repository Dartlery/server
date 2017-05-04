import 'package:di/di.dart';
import 'src/item_comparison_plugin.dart';
import 'package:dartlery/services/plugin_service.dart';

export 'src/a_plugin.dart';
export 'src/item_comparison_plugin.dart';


void instantiatePlugins(ModuleInjector parent) {
  // TODO: Set up dynamic plugin loader

  final Module module = new Module()
    ..bind(ItemComparisonPlugin);
  final ModuleInjector injector =  new ModuleInjector([module], parent);

  final PluginService service = injector.get(PluginService);
  service.addPlugin(injector.get(ItemComparisonPlugin));
}