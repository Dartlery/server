import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery/tools.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:image/image.dart';
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';
import 'package:option/option.dart';
import 'package:path/path.dart' as path;
import 'package:image_hash/image_hash.dart';
import 'package:dartlery/extrensions/extensions.dart';
import 'package:dartlery/services/extension_service.dart';
import 'a_file_upload_model.dart';

class ItemModel extends AIdBasedModel<Item> {
  static final Logger _log = new Logger('ItemModel');
  static final RegExp legalIdCharacters = new RegExp("[a-zA-Z0-9_\-]");


  static const List<String> supportedMimeTypes = const <String>[
    "image/jpeg",
    "image/gif",
    "image/png",
    'video/webm',
    'video/mp4',
    'application/x-shockwave-flash',
    'video/x-flv',
    'video/quicktime',
    'video/avi',
    'video/x-ms-asf',
    'video/mpeg'
  ];
  final AItemDataSource itemDataSource;
  final ATagDataSource tagDataSource;

  final ATagCategoryDataSource tagCategoryDataSource;

  final ExtensionService _extensionServices;

  // TODO: evaluate more (oh)
  ItemModel(this.itemDataSource, this.tagDataSource, this.tagCategoryDataSource, this._extensionServices,
      AUserDataSource userDataSource)
      : super(userDataSource);

  @override
  AItemDataSource get dataSource => itemDataSource;

  @override
  String get defaultDeletePrivilegeRequirement => UserPrivilege.normal;
  @override
  String get defaultReadPrivilegeRequirement => UserPrivilege.none;
  @override
  String get defaultWritePrivilegeRequirement => UserPrivilege.normal;

//  @override
//  _performAdjustments(Item item) {
//    // TODO: filter this down to just image fields?
//    for(String key in item.values.keys) {
//      item.values[key] = _handleImageLink(item.values[key]);
//    }
//  }

  @override
  Logger get loggerImpl => _log;

  @override
  Future<String> create(Item item,
      {bool bypassAuthentication: false, bool keepUuid: false}) async {
    if (!bypassAuthentication) {
      await validateCreatePrivileges();
      item.uploader = currentUserId;
    }

    item.id = "temporary";
    await validate(item);

    await _handleTags(item.tags);

    item.id = await _prepareFileUploads(item);
    item.uploaded = new DateTime.now();

    await _extensionServices.sendCreatingItem(item);

    final String itemId = await itemDataSource.create(item);

    return itemId;
  }

  Future<List<int>> generateFfmpegThumbnail(String originalFile) async {
    final String tempfile =
        path.join(Directory.systemTemp.path, "${generateUuid()}.png");
    try {
      final ProcessResult result = await Process.run("ffmpeg",
          ['-i', originalFile, '-vf', "thumbnail", '-frames:v', '1', tempfile]);
      if (result.exitCode != 0) {
        throw new Exception(
            "Error while generating video thumbnail: ${result.stderr.toString()}");
      }
      return await getFileData(tempfile);
    } finally {
      try {
        final File f = new File(tempfile);
        if (f.existsSync()) f.deleteSync();
      } catch (e, st) {
        _log.warning("Error while deleting thumbnail temp file", e, st);
      }
    }
  }

  Future<Image> _getRepresentativeImage(String hash, String mime, List<int> data) async {
    switch (mime) {
      case "image/jpeg":
        return decodeImage(data);
        break;
      case "image/gif":
      case "image/png":
      case "image/tiff":
      case "image/webp":
        try {
          Animation anim = decodeAnimation(data);
        return decodeImage(data);
        break;
      case 'video/webm':
      case 'video/mp4':
      case 'application/x-shockwave-flash':
      case 'video/x-flv':
      case 'video/quicktime':
      case 'video/avi':
      case 'video/x-ms-asf':
      case 'video/mpeg':
        return decodePng(await generateFfmpegThumbnail(getOriginalFilePathForHash(hash)));
        break;
      default:
        throw new Exception("MIME type not supported for thumbnailing: $mime");
    }
  }

  Future<Null> _createAndSaveThumbnail(Image image, String hash) async {
    if (!thumbnailDir.existsSync()) thumbnailDir.createSync(recursive: true);
    final List<int> thumbnailData = await _resizeImage(image);

    final File thumbnailFile = new File(getThumbnailFilePathForHash(hash));

    if (thumbnailFile.existsSync()) thumbnailFile.deleteSync();
    thumbnailFile.createSync(recursive: true);

    final RandomAccessFile thumbnailRaf =
        await thumbnailFile.open(mode: FileMode.WRITE_ONLY);

    try {
      _log.fine("Writing to ${thumbnailFile.path}");
      await thumbnailRaf.writeFrom(thumbnailData);
    } finally {
    try {
    await thumbnailRaf.close();
    } catch (e2, st) {
    _log.warning(e2, st);
    }
    }
  }

  @override
  Future<Item> getById(String uuid, {bool bypassAuthentication: false}) async {
    await validateGetPrivileges();

    final Item output =
        await super.getById(uuid, bypassAuthentication: bypassAuthentication);

    return output;
  }

  Future<PaginatedIdData<Item>> getVisible(
      {int page: 0, int perPage: defaultPerPage, DateTime cutoffDate}) async {
    if (page < 0) {
      throw new InvalidInputException("Page must be a non-negative number");
    }
    if (perPage < 0) {
      throw new InvalidInputException("Per-page must be a non-negative number");
    }
    await validateGetAllPrivileges();
    return await dataSource.getVisiblePaginated(this.currentUserId,
        page: page, perPage: perPage, cutoffDate: cutoffDate);
  }

  Future<List<int>> _resizeImage(Image image, {int maxDimension: 300}) async {
    Image thumbnail;
    if (image.width > image.height) {
      thumbnail = copyResize(image, maxDimension, -1, AVERAGE);
    } else {
      thumbnail = copyResize(image, -1, maxDimension, AVERAGE);
    }
    return encodeJpg(thumbnail, quality: 90);
  }

  Future<PaginatedIdData<Item>> searchVisible(List<Tag> tags,
      {int page: 0, int perPage: defaultPerPage,DateTime cutoffDate}) async {
    if (page < 0) {
      throw new InvalidInputException("Page must be a non-negative number");
    }
    if (perPage < 0) {
      throw new InvalidInputException("Per-page must be a non-negative number");
    }
    await validateSearchPrivileges();
    return await dataSource.searchVisiblePaginated(this.currentUserId, tags,
        page: page, perPage: perPage, cutoffDate: cutoffDate);
  }

  Future<Null> updateTags(String itemId, List<Tag> newTags, {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateUpdatePrivileges(itemId);

    if(!await itemDataSource.existsById(itemId))
      throw new NotFoundException("Item $itemId not found");

    await _handleTags(newTags);
    await itemDataSource.updateTags(itemId, newTags);
  }

  Future<Item> merge(String targetItemId, String sourceItemId, {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateUpdatePrivileges(targetItemId);
    if (!bypassAuthentication) await validateUpdatePrivileges(sourceItemId);

    final Option<Item> targetItem = await itemDataSource.getById(targetItemId);
    if(targetItem.isEmpty)
      throw new NotFoundException("Item $targetItemId not found");

    final Option<Item> sourceItem = await itemDataSource.getById(sourceItemId);
    if(sourceItem.isEmpty)
      throw new NotFoundException("Item $sourceItemId not found");

    final TagList newTagList = new TagList.from(targetItem.first.tags);
    for(Tag t in sourceItem.first.tags) {
      newTagList.add(t);
    }

    await itemDataSource.updateTags(targetItemId, newTagList.toList());
    await delete(sourceItemId);
    return (await itemDataSource.getById(targetItemId)).first;
  }

  @override
  Future<String> update(String id, Item item,
      {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateUpdatePrivileges(id);

    await _handleTags(item.tags);

    return await super
        .update(id, item, bypassAuthentication: bypassAuthentication);
  }

  @override
  Future<Null> validateFields(Item item, Map<String, String> fieldErrors,
      {String existingId: null}) async {
    //TODO: add dynamic field validation
    await super.validateFields(item, fieldErrors);

    if (StringTools.isNullOrWhitespace(existingId)) {
      if (item.fileData == null || item.fileData.length == 0) {
        fieldErrors["file"] = "Required";
      }
    }

    if (StringTools.isNullOrWhitespace(item.fileName)) {
      fieldErrors["fileName"] = "Required";
    }

    if (item.tags != null) {
      // TODO: Get the error feedback to be able to handle positional feedback
      for (Tag tag in item.tags) {
        if (StringTools.isNullOrWhitespace(tag.id)) {
          fieldErrors["id"] = "Tag name required";
        }
      }
    }
  }

  Future<Null> _handleTags(List<Tag> tags) async {
    for (Tag tag in tags) {
      final bool result = await tagDataSource.existsById(tag.id, tag.category);
      if (!result) {
        if(!StringTools.isNotNullOrWhitespace(tag.category)) {
          if (StringTools.isNotNullOrWhitespace(tag.category)&&
              !await tagCategoryDataSource.existsById(tag.category)) {
            final TagCategory cat = new TagCategory.withValues(tag.category);
            await tagCategoryDataSource.create(cat);
          }
        }
        await tagDataSource.create(tag);
      }
    }
  }

  Future<_PrepareFileResult> _prepareFileUpload(List<int> data) async {
    //      String image_url = getImagesRootUrl().toLowerCase();
//      if(value.toLowerCase().startsWith(image_url))
//        continue;
//      //TODO: Evaluate for abuse
//      // The server generates the image URL based on the HTTP request's server,
//      // so theoretically this should cover all real-world work cases,
//      // but if someone intentionally sent an image url from another accessible path to the server
//      // (ie, the ip address instead of domain name), it would end up downloading its own file.
//      // Since the file already exists, it would catch that it was the same file and abort,
//      // but there may be some way to abuse this. Have to think about it.

    if (data == null || data.length == 0)
      throw new InvalidInputException("Specified file data is empty");

    final Digest hash = sha256.convert(data);
    final String hashString = hash.toString();
    final _PrepareFileResult result = new _PrepareFileResult();
    result.hash = hashString;
    result.data = data;
    return result;
  }

  Future<String> _prepareFileUploads(Item item) async {
    item.length = item.fileData.length;
    final _PrepareFileResult result = await _prepareFileUpload(item.fileData);

    if (result == null) throw new Exception("No file processing result");

    final List<String> filesWritten = new List<String>();
    try {
      if (!originalFileDir.existsSync())
        originalFileDir.createSync(recursive: true);

      if (!thumbnailDir.existsSync()) thumbnailDir.createSync(recursive: true);

      final List<int> data = result.data;
      final String mime = mediaMimeResolver.getMimeType(data);

      if (StringTools.isNullOrWhitespace(mime)) {
        throw new InvalidInputException("Mime type of file is unknown");
      }

      item.mime = mime;

      if (!supportedMimeTypes.contains(mime)) {
        throw new InvalidInputException("Mime type not supported: $mime");
      }

      final File file = new File(getOriginalFilePathForHash(result.hash));
      bool fileExists = await file.exists();
      int size = 0;
      if(fileExists) {
        size = file.lengthSync();
        if(size==0) {
          file.deleteSync();
          fileExists = file.existsSync();
        }
      }

      if (!fileExists) {
        await file.create(recursive: true);
        final RandomAccessFile imageRaf =
        await file.open(mode: FileMode.WRITE_ONLY);
        try {
          _log.fine("Writing to ${file.path}");
          await imageRaf.writeFrom(data);
          filesWritten.add(file.path);
        } finally {
          try {
            // TODO: Create cleanup system so that database changes can be backed out of if there is a filesystem error
            // like a transaction object that can store the steps needed to reverse or commit everything.
            await imageRaf.close();
          } catch (e2, st) {
            _log.warning("Error while closing original file object", e2, st);
          }
        }
      } else if (size != data.length) {
          throw new Exception("File already exists with a different size");
      }


      try {
        Image representativeImage = await _getRepresentativeImage(result.hash, mime, data);
        item.height = representativeImage.height;
        item.width = representativeImage.width;
        representativeImage.duration = 'test';
        await _createAndSaveThumbnail(representativeImage, result.hash);
      } catch (e, st) {
        item.thumbnailError = e.toString();
        _log.warning(
            "Error while generating thumbnail for ${result.hash}", e, st);
      }

      return result.hash;
    } catch (e, st) {
      // TODO: Verify that when an item is deleted, that its files ends up going with them IF no other items reference that file
      _log.severe(e, st);
      for (String f in filesWritten) {
        try {
          final File file = new File(f);
          final bool exists = await file.exists();
          if (exists) await file.delete();
        } catch (e2, st) {
          _log.warning(e2, st);
        }
      }
      rethrow;
    }
  }

  @override
  Future<String> delete(String id) async {
    await _extensionServices.sendDeletingItem(id);
    final String output = await super.delete(id);

    try {
      final File file = new File(getOriginalFilePathForHash(id));
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e, st) {
      _log.warning("Error while deleting original file", e, st);
    }
    try {
      final File file = new File(getOriginalFilePathForHash(id));
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e, st) {
      _log.warning("Error while deleting thumbnail file", e, st);
    }

    return output;
  }
}

class _PrepareFileResult {
  String hash;
  List<int> data;
  //List<int> thumbnailData;
}
