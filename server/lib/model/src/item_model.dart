import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:dartlery/extrensions/extensions.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery/services/extension_service.dart';
import 'package:dartlery/tools.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:image/image.dart';
import 'package:image_hash/image_hash.dart';
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';
import 'package:option/option.dart';
import 'package:path/path.dart' as path;

import 'a_file_upload_model.dart';

class ItemModel extends AIdBasedModel<Item> {
  static final Logger _log = new Logger('ItemModel');
  static final RegExp legalIdCharacters = new RegExp("[a-zA-Z0-9_\-]");

  final AItemDataSource itemDataSource;
  final ATagDataSource tagDataSource;

  final ATagCategoryDataSource tagCategoryDataSource;

  final ExtensionService _extensionServices;

  // TODO: evaluate more (oh)
  ItemModel(this.itemDataSource, this.tagDataSource, this.tagCategoryDataSource,
      this._extensionServices, AUserDataSource userDataSource)
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

    await _handleFileUpload(item);
    item.uploaded = new DateTime.now();

    await _extensionServices.sendCreatingItem(item);

    final String itemId = await itemDataSource.create(item);

    return itemId;
  }

  @override
  Future<String> delete(String id) async {
    await _extensionServices.sendDeletingItem(id);
    final String output = await super.delete(id);

    try {
      final File file = new File(getFullFilePathForHash(id));
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e, st) {
      _log.warning("Error while deleting original file", e, st);
    }
    try {
      final File file = new File(getFullFilePathForHash(id));
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e, st) {
      _log.warning("Error while deleting thumbnail file", e, st);
    }

    return output;
  }

  Future<Null> getFfprobeData(Item item, String originalFile) async {
    ProcessResult result = await Process.run("ffprobe", [
      '-i',
      originalFile,
      '-show_entries',
      'format=duration',
      '-v',
      'quiet',
      '-of',
      'csv="p=0"'
    ]);
    if (result.exitCode != 0) {
      throw new Exception("Error while getting video duration: ${result.stderr
              .toString()}");
    }
    final double durationDouble = double.parse(result.stderr);
    item.duration = (durationDouble * 1000).floor();
    result = await Process.run("ffprobe", [
      '-i',
      originalFile,
      '-show_streams',
      '-select_streams',
      'a'
    ]);
    if (result.exitCode != 0) {
      throw new Exception("Error while getting audio sream data: ${result.stderr
          .toString()}");
    }
    item.audio = result.stderr.toString().contains("[STREAM]");


  }

  Future<List<int>> generateFfmpegThumbnail(String originalFile) async {
    final Directory tempFolder = await Directory.systemTemp.createTemp("dartlery_ffempeg_output");
    final String tempfile =
        path.join(tempFolder.path, "thumbnail.png");
    try {
      final ProcessResult result = await Process.run("ffmpeg",
          ['-i', originalFile, '-vf', "thumbnail", '-frames:v', '1', tempfile]);
      if (result.exitCode != 0) {
        throw new Exception(
            "Error while generating video thumbnail: ${result.stderr
                .toString()}");
      }
      return await getFileData(tempfile);
    } finally {
      try {
        await tempFolder.delete(recursive: true);
      } catch (e, st) {
        _log.warning("Error while deleting thumbnail temp file", e, st);
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

  Future<Item> merge(String targetItemId, String sourceItemId,
      {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateUpdatePrivileges(targetItemId);
    if (!bypassAuthentication) await validateUpdatePrivileges(sourceItemId);

    final Option<Item> targetItem = await itemDataSource.getById(targetItemId);
    if (targetItem.isEmpty)
      throw new NotFoundException("Item $targetItemId not found");

    final Option<Item> sourceItem = await itemDataSource.getById(sourceItemId);
    if (sourceItem.isEmpty)
      throw new NotFoundException("Item $sourceItemId not found");

    final TagList newTagList = new TagList.from(targetItem.first.tags);
    for (Tag t in sourceItem.first.tags) {
      newTagList.add(t);
    }

    await itemDataSource.updateTags(targetItemId, newTagList.toList());
    await delete(sourceItemId);
    return (await itemDataSource.getById(targetItemId)).first;
  }

  Future<PaginatedIdData<Item>> searchVisible(List<Tag> tags,
      {int page: 0, int perPage: defaultPerPage, DateTime cutoffDate}) async {
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

  @override
  Future<String> update(String id, Item item,
      {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateUpdatePrivileges(id);

    await _handleTags(item.tags);

    return await super
        .update(id, item, bypassAuthentication: bypassAuthentication);
  }

  Future<Null> updateTags(String itemId, List<Tag> newTags,
      {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateUpdatePrivileges(itemId);

    if (!await itemDataSource.existsById(itemId))
      throw new NotFoundException("Item $itemId not found");

    await _handleTags(newTags);
    await itemDataSource.updateTags(itemId, newTags);
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

  Future<File> _createAndSaveThumbnail(Image image, String hash) async {
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

    return thumbnailFile;
  }

  Future<Null> _handleFileUpload(Item item) async {
    item.length = item.fileData.length;

    final List<int> data = item.fileData;
    item.id = generateHash(data);

    if (StringTools.isNullOrWhitespace(item.id))
      throw new Exception("No hash generated for file data");

    final List<FileSystemEntity> filesWritten = <FileSystemEntity>[];

    try {
      if (!originalDir.existsSync()) originalDir.createSync(recursive: true);
      if (!fullFileDir.existsSync()) fullFileDir.createSync(recursive: true);
      if (!thumbnailDir.existsSync()) thumbnailDir.createSync(recursive: true);

      final String mime = mediaMimeResolver.getMimeType(data);

      if (StringTools.isNullOrWhitespace(mime)) {
        throw new InvalidInputException("Mime type of file is unknown");
      }

      item.mime = mime;

      filesWritten.add(await _writeBytes(getOriginalFilePathForHash(item.id), item.fileData));

      Image originalImage;
      if (MimeTypes.imageTypes.contains(mime)) {
        originalImage = decodeImage(item.fileData);
        if (MimeTypes.animatableImageTypes.contains(mime)) {
          try {
            final Animation anim = decodeAnimation(data);
            item.video = true;
            item.duration = 0;
            for (Image i in anim) {
              item.duration += i.duration;
            }
          } catch (e, st) {
            // Not an animation
            _log.finest("Not an animation!", e, st);
          }
        }
      } else if (MimeTypes.videoTypes.contains(mime)) {
        item.video = true;
        originalImage = decodePng(
            await generateFfmpegThumbnail(getOriginalFilePathForHash(item.id)));
        await getFfprobeData(item, getOriginalFilePathForHash(item.id));
      }
      item.height = originalImage.height;
      item.width = originalImage.width;

      if (MimeTypes.webFriendlyTypes.contains(mime)) {
    filesWritten.add(await new Link(getFullFilePathForHash(item.id))
            .create(getOriginalFilePathForHash(item.id)));
      } else {
    filesWritten.add(await _writeBytes(getFullFilePathForHash(item.id),
            encodeJpg(originalImage, quality: 90)));
      }


      try {
        filesWritten.add(await _createAndSaveThumbnail(originalImage, item.id));
      } catch (e, st) {
        item.thumbnailError = e.toString();
        _log.warning("Error while generating thumbnail for ${item.id}", e, st);
      }
    } catch (e, st) {
      _log.severe(e, st);
      for (FileSystemEntity fse in filesWritten) {
        try {
          final bool exists = await fse.exists();
          if (exists) await fse.delete();
        } catch (e2, st) {
          _log.warning(e2, st);
        }
      }
      rethrow;
    }
  }

  Future<Null> _handleTags(List<Tag> tags) async {
    for (Tag tag in tags) {
      final bool result = await tagDataSource.existsById(tag.id, tag.category);
      if (!result) {
        if (!StringTools.isNotNullOrWhitespace(tag.category)) {
          if (StringTools.isNotNullOrWhitespace(tag.category) &&
              !await tagCategoryDataSource.existsById(tag.category)) {
            final TagCategory cat = new TagCategory.withValues(tag.category);
            await tagCategoryDataSource.create(cat);
          }
        }
        await tagDataSource.create(tag);
      }
    }
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

  Future<File> _writeBytes(String path, List<int> bytes) async {
    final File file = new File(path);
    bool fileExists = await file.exists();
    int size = 0;
    if (fileExists) {
      size = file.lengthSync();
      if (size == 0) {
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
        await imageRaf.writeFrom(bytes);
      } finally {
        try {
          await imageRaf.close();
        } catch (e2, st) {
          _log.warning("Error while closing file object", e2, st);
        }
      }
    } else {
      throw new Exception("File already exists with a different size");
    }
    return file;
  }
}
