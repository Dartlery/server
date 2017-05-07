import 'dart:async';
import 'dart:io';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:image/image.dart';
import 'package:image_hash/image_hash.dart';
import 'package:logging/logging.dart';
import 'package:option/option.dart';

import 'a_extension.dart';

class ItemComparisonExtension extends AExtension {
  static final Logger _log = new Logger('ItemComparisonPlugin');

  static const String pluginIdStatic = "itemComparison";

  static const int similarityCutoff = 50;

  static const String perceptualHashKeyName = "perceptualHash";
  static const String similarItemsKeyName = "similarItems";

  final AItemDataSource _itemDataSource;
  final ExtensionDataModel _extensionDataModel;
  final ABackgroundQueueDataSource _backgroundQueueDataSource;

  ItemComparisonExtension(this._itemDataSource, this._backgroundQueueDataSource,
      this._extensionDataModel);
  @override
  String get extensionId => pluginIdStatic;

  @override
  Future<Null> onBackgroundCycle(BackgroundQueueItem item) async {
    try {
      final Option<Item> sourceItem = await _itemDataSource.getById(item.data);

      if (sourceItem.isEmpty) return;
      if (!MimeTypes.imageTypes.contains(sourceItem.first.mime)) return;

      final ImageHash sourceHash = await _getPerceptualHash(item.data);


      final Stream<Item> itemStream = await _itemDataSource.streamAll();

      await for (Item targetItem in itemStream) {

        if (sourceItem.first.id == targetItem.id) continue;
          if (!MimeTypes.imageTypes.contains(targetItem.mime)) continue;

          try {
            if (await _checkForComparisonResult(
                sourceItem.first.id, targetItem.id)) continue;

            final ImageHash targetHash =
                await _getPerceptualHash(targetItem.id);

            final double result = sourceHash.compareTo(targetHash);

            if (result < similarityCutoff) continue;

            await _recordComparisonResult(
                sourceItem.first.id, targetItem.id, result);
          } catch (e, st) {
            _log.warning(e, st);
          }
      }
    } catch (e, st) {
      _log.severe(e, st);
    }
  }

  @override
  Future<Null> onDeletingItem(String itemId) async {
    try {
      await _extensionDataModel.delete(extensionId, perceptualHashKeyName, primaryId: itemId);
      await _extensionDataModel.deleteBidirectional(extensionId, similarItemsKeyName, itemId);
    } catch(e,st) {
      _log.warning(e,st);
    }

  }

  @override
  Future<Null> onCreatingItem(Item item) async {
    if(item.id=="94795b7b0c8c4b09cd455a09c14961ac44bc807eb0617a4b3b791db34a3b52e7")
      _log.info(item);
    try {
      if (MimeTypes.imageTypes.contains(item.mime)) {
        await _backgroundQueueDataSource.addToQueue(this.extensionId, item.id);
      }
    } catch (e, st) {
      _log.severe("Error queueing image comparison for ${e.item.id}", e, st);
    }
  }

  Future<bool> _checkForComparisonResult(String itemId1, String itemId2) async {
    try {
      // TODO: Switch these to expects to save resources
      if (itemId1.compareTo(itemId2) < 0) {
        await _extensionDataModel.getSpecific(extensionId, similarItemsKeyName,
            primaryId: itemId1, secondaryId: itemId2);
      } else {
        await _extensionDataModel.getSpecific(extensionId, similarItemsKeyName,
            primaryId: itemId2, secondaryId: itemId1);
      }
      return true;
    } on NotFoundException {
      return false;
    }
  }

  Future<ImageHash> _getPerceptualHash(String imageID) async {
    try {
      final ExtensionData data = await _extensionDataModel
          .getSpecific(extensionId, perceptualHashKeyName, primaryId: imageID);
      if (data.value != null) {
        return new ImageHash.parse(data.value.toString());
      }
    } on NotFoundException {
      // Hash hasn't been generated, have to make it
    }
    final String fileName = getFullFilePathForHash(imageID);

    final File f = new File(fileName);
    if (!f.existsSync()) return null;

    final ImageHash imageHash =
        new ImageHash.forImage(decodeImage(f.readAsBytesSync()), size: 16);

    final String perceptualHash = imageHash.toString();
    _log.info("Perceptual hash: ${perceptualHash}");

    final ExtensionData newData = new ExtensionData();
    newData.extensionId = extensionId;
    newData.key = perceptualHashKeyName;
    newData.primaryId = imageID;
    newData.value = perceptualHash;
    await _extensionDataModel.set(newData);

    return imageHash;
  }

  Future<Null> _recordComparisonResult(
      String itemId1, String itemId2, double result) async {
    final ExtensionData data = new ExtensionData();
    data.extensionId = extensionId;
    data.key = similarItemsKeyName;
    data.value = result;
    if (itemId1.compareTo(itemId2) < 0) {
      data.primaryId = itemId1;
      data.secondaryId = itemId2;
    } else {
      data.primaryId = itemId2;
      data.secondaryId = itemId1;
    }
    await _extensionDataModel.set(data);
  }
}
