import 'dart:async';
import 'a_extension.dart';
import 'package:dartlery/data/data.dart';
import 'package:logging/logging.dart';
import 'package:dartlery/model/model.dart';

class ImportPathExtension extends AExtension {
  static final Logger _log = new Logger('ImportPathExtension');

  static const String pluginIdStatic = "importPath";

  final ImportModel _importModel;

  ImportPathExtension(this._importModel);

  @override
  String get extensionId => pluginIdStatic;

  @override
  Future<Null> onBackgroundCycle(BackgroundQueueItem queueItem) async {
    try {
      final Map data = queueItem.data;
      await _importModel.importFromPath(data["path"],
          stopOnError: data["stopOnError"],
          interpretShimmieNames: data["interpretShimmieNames"],
          overrideBatchTimestamp: data["batchTimestamp"],
          mergeExisting: data["mergeExisting"]);
    } catch (e, st) {
      _log.severe(e, st);
    } finally {}
  }
}
