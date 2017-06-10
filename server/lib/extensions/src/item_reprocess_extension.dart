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

class ItemReprocessExtension extends AExtension {
  static final Logger _log = new Logger('ItemReprocessExtension');

  static const String pluginIdStatic = "itemReprocess";

  final ItemModel _itemModel;
  final AItemDataSource _itemDataSource;

  ItemReprocessExtension(this._itemModel, this._itemDataSource);
  @override
  String get extensionId => pluginIdStatic;

  @override
  Future<Null> onBackgroundCycle(BackgroundQueueItem queueItem) async {
    try {
      final Item item =
          await _itemModel.getById(queueItem.data, bypassAuthentication: true);
      item.errors.clear();
      final File f = new File(getOriginalFilePathForHash(queueItem.data));
      item.fileData = f.readAsBytesSync();
      await _itemModel.processItem(item);
      await _itemModel.update(item.id, item, bypassAuthentication: true);
    } catch (e, st) {
      _log.severe(e, st);
    } finally {}
  }
}
