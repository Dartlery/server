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

class ItemModel extends AIdBasedModel<Item> {
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
      {bool bypassAuthentication: false,
      bool keepUuid: false}) async {
    await validateCreatePrivileges();

    item.id = generateUuid();

    await validate(item);

    await _handleTags(item.tags);
    item.id = await _prepareFileUploads(item);
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
  Future<String> update(String id, Item item,
      {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateUpdatePrivileges(id);

    await _handleTags(item.tags);
    if(item.fileData!=null) {
      item.id = await _prepareFileUploads(item);
    }

    return await super
        .update(id, item, bypassAuthentication: bypassAuthentication);
  }

  @override
  Future<Null> validateFields(Item item, Map<String, String> fieldErrors,
      {String existingId: null}) async {
    //TODO: add dynamic field validation
    await super.validateFields(item, fieldErrors);

    if(StringTools.isNullOrWhitespace(existingId)) {
      if (item.fileData == null || item.fileData.length == 0) {
        fieldErrors["file"] = "Required";
      }
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
      final bool result = await tagDataSource.existsById(tag.id, tag.category);
      if(!result) {
        await tagDataSource.create(tag);
      }
    }
  }

  Future<_PrepareFileResult> _prepareFileUpload(
      List<int> data) async {
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



    if (data==null||data.length == 0)
      throw new InvalidInputException("Specified file data is empty");

    final Digest hash = sha256.convert(data);
    final String hashString = hash.toString();
    final _PrepareFileResult result = new _PrepareFileResult();
    result.hash = hashString;
    result.data = data;
    return result;
  }

  static const List<String> supportedMimeTypes = const <String> [
    "image/jpeg", "image/gif"
  ];

  String getMimeType(List<int> data) {
    List<int> lookupBytes;
    if (data.length > 10) {
      lookupBytes = data.sublist(0, 10);
    } else {
      lookupBytes = data;
    }
    return lookupMimeType("", headerBytes: lookupBytes);
  }

  Future<Null> generateThumbnail(String hash, String mime, List<int> data) async {
    if (!thumbnailDir.existsSync()) thumbnailDir.createSync(recursive: true);
    List<int> thumbnailData;
    switch (mime) {
      case "image/jpeg":
      case "image/gif":
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
    new File(path.join(thumbnailImagePath, hash));

    if (thumbnailFile.existsSync()) thumbnailFile.deleteSync();
    thumbnailFile.createSync();

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

  Future<String> _prepareFileUploads(Item item) async {
    final _PrepareFileResult result =
        await _prepareFileUpload(item.fileData);
    if (result == null)
      throw new Exception("No file processing result");

    final List<String> filesWritten = new List<String>();
    try {
      if (!originalFileDir.existsSync())
        originalFileDir.createSync(recursive: true);
      if (!thumbnailDir.existsSync()) thumbnailDir.createSync(recursive: true);


      final List<int> data = result.data;
      final String mime = getMimeType(data);

      if(!supportedMimeTypes.contains(mime)) {
        throw new InvalidInputException("Mime type not supported: $mime");
      }

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
          return result.hash;
          //throw new Exception("File already exists on server");
      }

      final RandomAccessFile imageRaf =
          await file.open(mode: FileMode.WRITE_ONLY);
      try {
        _log.fine("Writing to ${file.path}");
        await imageRaf.writeFrom(data);
        filesWritten.add(file.path);
      } finally {
        try {
          await imageRaf.close();
        } catch (e2, st) {
          _log.warning(e2, st);
        }
      }
      try {
          await generateThumbnail(result.hash, mime, data);
      } catch(e,st) {
        _log.warning("Error while generating thumbnail for ${result.hash}",e,st);
      }
      
      return result.hash;
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
  List<int> data;
  //List<int> thumbnailData;
}
