import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:image/image.dart';
import 'package:image_hash/image_hash.dart';
import 'package:logging/logging.dart';
import 'package:option/option.dart';

import 'a_plugin.dart';

class ItemComparisonPlugin extends APlugin {
  static final Logger _log = new Logger('ItemComparisonPlugin');

  static const String pluginIdStatic = "itemComparison";

  static const int similarityCutoff = 0;

  static const String perceptualHashFieldName =
      "${pluginIdStatic}PerceptualHash";
  static const String similarItemsFieldName = "${pluginIdStatic}SimilarItems";

  final AItemDataSource _itemDataSource;

  final ABackgroundQueueDataSource _backgroundQueueDataSource;

  ItemComparisonPlugin(this._itemDataSource, this._backgroundQueueDataSource);
  @override
  String get pluginId => pluginIdStatic;

  @override
  Future<Null> onBackgroundCycle(BackgroundQueueItem item) async {
    try {
      final Option<Item> sourceItem = await _itemDataSource.getById(item.data);
      if (sourceItem.isEmpty) return;
      if (StringTools.isNullOrWhitespace(
          sourceItem.first.pluginData[perceptualHashFieldName])) return;

      final ImageHash sourceHash = new ImageHash.parse(
          sourceItem.first.pluginData[perceptualHashFieldName]);
      PaginatedData<Item> items = await _itemDataSource.getAllPaginated();
      if (sourceItem.first.pluginData[similarItemsFieldName] != null)
        _log.info("test");

      final Map<String, double> results =
          sourceItem.first.pluginData[similarItemsFieldName] ??
              <String, double>{};
      while (items.count > 0) {
        for (Item targetItem in items.data) {
          if(sourceItem.first.id==targetItem.id)
            continue;
          try {
            final Map<String, double> targetResults =
                targetItem.pluginData[similarItemsFieldName] ??
                    <String, double>{};

            if (results.containsKey(targetItem.id)) {
              if (!targetResults.containsKey(sourceItem.first.id)) {
                targetResults[sourceItem.first.id] = results[targetItem.id];
                await _itemDataSource.updatePluginData(targetItem.id,
                    <String, dynamic>{similarItemsFieldName: targetResults});
              }
              continue;
            }
            if (targetResults.containsKey(sourceItem.first.id)) {
              results[targetItem.id] = targetResults[sourceItem.first.id];
              continue;
            }

            if (StringTools.isNullOrWhitespace(
                targetItem.pluginData[perceptualHashFieldName])) continue;
            final ImageHash targetHash = new ImageHash.parse(
                targetItem.pluginData[perceptualHashFieldName]);
            final double result = sourceHash.compareTo(targetHash);
            results[targetItem.id] = result;

            targetResults[sourceItem.first.id] = result;
            await _itemDataSource.updatePluginData(targetItem.id,
                <String, dynamic>{similarItemsFieldName: targetResults});
          } catch (e, st) {
            _log.warning(e, st);
          }
        }
        items =
            await _itemDataSource.getAllPaginated(page: items.currentPage + 1);
      }
      await _itemDataSource.updatePluginData(sourceItem.first.id,
          <String, dynamic>{similarItemsFieldName: results});
    } catch (e, st) {
      _log.severe(e, st);
    }
  }

  @override
  Future<Null> onCreatingItem(Item item) async {
    try {
      if (imageMimeTypes.contains(item.mime)) {
        final ImageHash imageHash =
            new ImageHash.forImage(decodeImage(item.fileData), size: 16);
        final String perceptualHash = imageHash.toString();
        _log.info("Perceptual hash: ${perceptualHash}");
        item.pluginData[perceptualHashFieldName] = perceptualHash;
        await _backgroundQueueDataSource.addToQueue(this.pluginId, item.id);
      }
    } catch (e, st) {
      _log.severe(
          "Error while generating perceptual hash for ${e.item.id}", e, st);
    }
  }
}
