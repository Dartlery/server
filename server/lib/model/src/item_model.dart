import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:image/image.dart';
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';
import 'package:option/option.dart';
import 'package:path/path.dart' as path;

import 'a_file_upload_model.dart';

class ItemModel extends AIdBasedModel<Item> with AFileUploadModel<Item> {
  static final Logger _log = new Logger('ItemModel');
  static final RegExp legalIdCharacters = new RegExp("[a-zA-Z0-9_\-]");

  static final String originalFilePath =
      path.join(rootDirectory, hostedFilesOriginalsPath);

  static final String thumbnailImagePath =
      path.join(rootDirectory, hostedFilesThumbnailsPath);

  static final Directory originalFileDir = new Directory(originalFilePath);

  static final Directory thumbnailDir = new Directory(thumbnailImagePath);

  final AItemDataSource itemDataSource;
  final ATagDataSource tagDataSource;
  final ATagCategoryDataSource tagCategoryDataSource;

  ItemModel(this.itemDataSource, this.tagDataSource, this.tagCategoryDataSource,
      AUserDataSource userDataSource)
      : super(userDataSource);

  // TODO: evaluate more (oh)
  @override
  AItemDataSource get dataSource => itemDataSource;

  @override
  String get defaultDeletePrivilegeRequirement => UserPrivilege.admin;

  @override
  String get defaultReadPrivilegeRequirement => UserPrivilege.none;
  @override
  String get defaultWritePrivilegeRequirement => UserPrivilege.normal;
  @override
  Logger get loggerImpl => _log;

//  @override
//  _performAdjustments(Item item) {
//    // TODO: filter this down to just image fields?
//    for(String key in item.values.keys) {
//      item.values[key] = _handleImageLink(item.values[key]);
//    }
//  }

  @override
  Future<String> create(Item item,
      {List<List<int>> files,
      bool bypassAuthentication: false,
      bool keepUuid: false}) async {
    await validateCreatePrivileges();

    item.id = generateUuid();

    await validate(item);

    await _prepareFileUploads(item, files);
    await _handleTags(item.tags);

    //TODO: More thorough cleanup of files in case of failure

    final String itemId = await itemDataSource.create(item.id, item);
    return itemId;
  }

  @override
  Future<Item> getById(String uuid, {bool bypassAuthentication: false}) async {
    await validateGetPrivileges();

    final Item output =
        await super.getById(uuid, bypassAuthentication: bypassAuthentication);

    return output;
  }

  Future<PaginatedIdData<Item>> getVisible(
      {int page: 0, int perPage: defaultPerPage}) async {
    if (page < 0) {
      throw new InvalidInputException("Page must be a non-negative number");
    }
    if (perPage < 0) {
      throw new InvalidInputException("Per-page must be a non-negative number");
    }
    await validateGetAllPrivileges();
    return await dataSource.getVisiblePaginated(this.currentUserUuid,
        page: page, perPage: perPage);
  }

  Future<PaginatedIdData<Item>> searchVisible(String query,
      {int page: 0, int perPage: defaultPerPage}) async {
    if (page < 0) {
      throw new InvalidInputException("Page must be a non-negative number");
    }
    if (perPage < 0) {
      throw new InvalidInputException("Per-page must be a non-negative number");
    }
    await validateSearchPrivileges();
    return await dataSource.searchVisiblePaginated(this.currentUserUuid, query,
        page: page, perPage: perPage);
  }

  @override
  Future<String> update(String uuid, Item item,
      {List<List<int>> files, bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateUpdatePrivileges(uuid);

    await _prepareFileUploads(item, files);

    await _handleTags(item.tags);

    return await super
        .update(uuid, item, bypassAuthentication: bypassAuthentication);
  }

  @override
  Future<Null> validateFields(Item item, Map<String, String> fieldErrors,
      {String existingId: null}) async {
    //TODO: add dynamic field validation
    await super.validateFields(item, fieldErrors);

    if(StringTools.isNullOrWhitespace(item.file)) {
      fieldErrors["file"] = "Required";
    }

    if (item.tags != null) {
      // TODO: Get the error feedback to be able to handle positional feedback
      for (Tag tag in item.tags) {
        if (StringTools.isNullOrWhitespace(tag.id)) {
          fieldErrors["id"] = "Tag name required";
        }

        if (StringTools.isNotNullOrWhitespace(tag.category)) {
          final Option<TagCategory> result =
              await tagCategoryDataSource.getById(tag.category);
          if (result.isEmpty) fieldErrors["tag"] = "Not found";
        }
      }
    }
  }

  Future<Null> _handleTags(List<Tag> tags) async {
    for (Tag tag in tags) {
      if (StringTools.isNullOrWhitespace(tag.id)) {
        tag.id = generateUuid();
        await tagDataSource.create(tag.id, tag);
      }
    }
  }

  Future<_PrepareFileResult> _prepareFileUpload(
      String fileId, List<List<int>> files) async {
    if (StringTools.isNullOrWhitespace(fileId) ||
        fileId.startsWith(hostedFilesPrefix)) {
      // This should indicate that the submitted image is one that is already hosted on the server, so nothing to do here
      return null;
    }
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

    List<int> data;

    final Match m = fileUploadRegex.firstMatch(fileId);
    if (m != null) {
      // This is a new file upload
      final int filePosition = int.parse(m.group(1));
      if (files.length - 1 < filePosition) {
        throw new InvalidInputException(
            "Unprovided upload file specified at position $filePosition");
      }
      data = files[filePosition];
    } else {
      // So we assume it's a URL
      _log.fine("Processing as URL: $fileId");
      final Uri fileUri = Uri.parse(fileId);
      final HttpClientRequest req = await new HttpClient().getUrl(fileUri);
      final HttpClientResponse response = await req.close();
      final List<List<int>> output = await response.toList();
      data = new List<int>();
      for (List<int> chunk in output) {
        data.addAll(chunk);
      }
    }

    if (data.length == 0)
      throw new InvalidInputException("Specified file upload $fileId is empty");

    final Digest hash = sha256.convert(data);
    final String hashString = hash.toString();
    final _PrepareFileResult result = new _PrepareFileResult();
    result.hash = hashString;
    result.data = data;
    result.fileSpecifier = "$hostedFilesPrefix$hashString";
    return result;
  }

  Future<Null> _prepareFileUploads(Item item, List<List<int>> files) async {
    final _PrepareFileResult result =
        await _prepareFileUpload(item.file, files);
    if (result == null)
      return;
    item.file = result.fileSpecifier;

    final List<String> filesWritten = new List<String>();
    try {
      if (!originalFileDir.existsSync())
        originalFileDir.createSync(recursive: true);
      if (!thumbnailDir.existsSync()) thumbnailDir.createSync(recursive: true);

      final List<int> data = result.data;

      final File file = new File(path.join(originalFilePath, result.hash));
      final bool fileExists = await file.exists();
      if (!fileExists) {
        await file.create();
      } else {
        final int size = await file.length();
        if(size==0)
          await file.delete();
        if (size != data.length)
          throw new Exception("File already exists with a different size");
        else
          return;
      }

      List<int> lookupBytes;
      if (data.length > 10) {
        lookupBytes = data.sublist(0, 10);
      } else {
        lookupBytes = data;
      }
      final String mime = lookupMimeType("", headerBytes: lookupBytes);

      List<int> thumbnailData;
      switch (mime) {
        case "image/jpeg":
          final Image image = decodeImage(data);
          if (image.width > 300) {
            final Image thumbnail = copyResize(image, 300, -1, AVERAGE);
            thumbnailData = encodeJpg(thumbnail, quality: 90);
          } else {
            thumbnailData = data;
          }
          break;
        default:
          throw new Exception("MIME type not supported: $mime");
      }

      final File thumbnailFile =
          new File(path.join(thumbnailImagePath, result.hash));

      if (thumbnailFile.existsSync()) thumbnailFile.deleteSync();
      thumbnailFile.createSync();

      final RandomAccessFile imageRaf =
          await file.open(mode: FileMode.WRITE_ONLY);
      final RandomAccessFile thumbnailRaf =
          await thumbnailFile.open(mode: FileMode.WRITE_ONLY);
      try {
        _log.fine("Writing to ${file.path}");
        await imageRaf.writeFrom(data);
        filesWritten.add(file.path);
        _log.fine("Writing to ${thumbnailFile.path}");
        await thumbnailRaf.writeFrom(thumbnailData);
        filesWritten.add(thumbnailFile.path);
      } finally {
        try {
          await imageRaf.close();
        } catch (e2, st) {
          _log.warning(e2, st);
        }
        try {
          await thumbnailRaf.close();
        } catch (e2, st) {
          _log.warning(e2, st);
        }
      }
    } catch (e, st) {
      // TODO: Verify that when an item is deleted, that its files ends up going with them IF no other items reference that file
      _log.severe(e.message, e, st);
      for (String f in filesWritten) {
        try {
          final File file = new File(f);
          final bool exists = await file.exists();
          if (exists) await file.delete();
        } catch (e2, st) {
          _log.warning(e2, st);
        }
      }
      throw e;
    }
  }
}

class _PrepareFileResult {
  String hash;
  String fileSpecifier;
  List<int> data;
}
