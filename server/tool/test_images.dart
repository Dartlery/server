import 'dart:async';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart' as server_logging;
import 'package:dartlery/tools.dart';
import 'package:dartlery_shared/global.dart';
import 'package:image/image.dart';

Future<Null> main(List<String> args) async {
  Logger.root.onRecord.listen(new server_logging.LogPrintHandler());
  Logger.root.onRecord.listen(new server_logging.SyncFileLoggingHandler("image_test.log"));
  final Logger _log = new Logger("test_images.main()");

  final Directory dir = new Directory("data/original");

  await for(FileSystemEntity entity in dir.list(recursive: true)) {
    try {
      if (entity is File) {
        final File f = entity;
        _log.info("File: ${f.path}");

        final String mime = await mediaMimeResolver.getMimeTypeForFile(f.path);
        _log.info("Mime: $mime");

        if (MimeTypes.imageTypes.contains(mime)) {
          _log.info("Is image MIME type");

          // This is being implemented to test the new JPEG decoder, so for now we're just looking at jpeg files
          if (mime != MimeTypes.jpeg)
            continue;

          final List<int> data = await getFileData(f.path);
          if (MimeTypes.animatableImageTypes.contains(mime)) {
            _log.info("Is animatable image MIME type");
            try {
              _log.info("Decoding animation");
              decodeAnimation(data);
              _log.info("Animation decoded");
            } catch (e, st) {
              // Not an animation
              _log.info("Not an animation!", e, st);
              decodeImage(data);
            }
          } else {
            _log.info("Decoding image");
            decodeImage(data);
            _log.info("image decoded");
          }
        }
      }
    } catch (e,st) {
      _log.severe(e,st);
    }
  }
}