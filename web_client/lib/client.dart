import 'package:dartlery_shared/global.dart';
import 'package:path/path.dart' as path;
import 'package:lib_angular/tools.dart';

/// Determines the appropriate URL to get an image from the server's image store.
String getImageUrl(String image, ItemFileType type) {
  switch (type) {
    case ItemFileType.full:
      return path.join(
          getServerRoot(), hostedFilesFullPath, image.substring(0, 2), image);
    case ItemFileType.thumbnail:
      return path.join(getServerRoot(), hostedFilesThumbnailsPath,
          image.substring(0, 2), image);
    case ItemFileType.original:
      return path.join(getServerRoot(), hostedFilesOriginalPath,
          image.substring(0, 2), image);
    default:
      throw new Exception("Not supported: $type");
  }
}

/// Defines the different image types that can be requested from the server.
enum ItemFileType {
  original,

  /// The original full size file, or the web-friendly version thereof.
  full,

  /// A scaled-down, slightly more compressed, version of an original image file.
  thumbnail
}

/// Indicates that a data validation related error occured.
class ValidationException implements Exception {
  /// Validation error message.
  String message;

  /// Creates an instance of [ValidationException] with an error message.
  ValidationException(this.message);
}
