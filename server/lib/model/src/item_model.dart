import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/server.dart';
import 'package:dartlery/services/extension_service.dart';
import 'package:dartlery/tools.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as image;
import 'package:logging/logging.dart';
import 'package:option/option.dart';
import 'package:path/path.dart' as path;

class ItemModel extends AIdBasedModel<Item> {
  static final Logger _log = new Logger('ItemModel');
  static final RegExp legalIdCharacters = new RegExp("[a-zA-Z0-9_\-]");

  static const int jpegQuality = 90;

  final AItemDataSource itemDataSource;
  final ATagDataSource tagDataSource;
  final TagModel _tagModel;

  final ATagCategoryDataSource tagCategoryDataSource;

  final ExtensionService _extensionServices;

  // TODO: evaluate more (oh)
  final RegExp _codecNameRegex =
      new RegExp(r"^codec_long_name=(.+)$", multiLine: true);

  final RegExp _audioSampleRateRegex =
      new RegExp(r"^sample_rate=(.+)$", multiLine: true);

  final RegExp _bitRateRegex = new RegExp(r"^bit_rate=(.+)$", multiLine: true);

  final RegExp _audioChannelsRegex =
      new RegExp(r"^channels=(.+)$", multiLine: true);

  final RegExp _videoPixelFormatRegex =
      new RegExp(r"^pix_fmt=(.+)$", multiLine: true);

  DateFormat downloadNameDateFormat = new DateFormat('yMdHms');

  Future<Null> adjustAll(Iterable<Item> items) async {
    for (Item i in items) {
      await performAdjustments(i);
    }
  }

  @override
  Future<Null> performAdjustments(Item t) async {
    final StringBuffer downloadName = new StringBuffer();
    downloadName.write(t.uploaded.year.toString().substring(2, 4));
    downloadName.write(t.uploaded.month.toString().padLeft(2, '0'));
    downloadName.write(t.uploaded.day.toString().padLeft(2, '0'));
    downloadName.write(t.uploaded.hour.toString().padLeft(2, '0'));
    downloadName.write(t.uploaded.minute.toString().padLeft(2, '0'));
    downloadName.write(t.uploaded.second.toString().padLeft(2, '0'));
    downloadName.write(t.uploaded.millisecond.toString().padLeft(3, '0'));

    downloadName.write(" - ");
    downloadName.write(t.tags.join(" ").replaceAll(":", ","));

    if (!MimeTypes.extensions.containsKey(t.mime)) {
      throw new Exception("Don't know extension for mime type: ${t.mime}");
    }
    downloadName.write(".");
    downloadName.write(MimeTypes.extensions[t.mime]);
    t.downloadName = downloadName.toString();
  }

  final RegExp _videoFrameRateRegex =
      new RegExp(r"^avg_frame_rate=(\d+)\/(\d+)$", multiLine: true);

  ItemModel(this.itemDataSource, this.tagDataSource, this.tagCategoryDataSource,
      this._extensionServices, this._tagModel, AUserDataSource userDataSource)
      : super(userDataSource);

  @override
  AItemDataSource get dataSource => itemDataSource;

  @override
  String get defaultDeletePrivilegeRequirement => UserPrivilege.normal;

  @override
  String get defaultReadPrivilegeRequirement => UserPrivilege.normal;

  @override
  String get defaultWritePrivilegeRequirement => UserPrivilege.normal;
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

    await _handleFileUpload(item);

    await _tagModel.handleTags(item.tags, createTags: true);

    item.uploaded = new DateTime.now();

    await _extensionServices.sendCreatingItem(item);

    final String itemId = await itemDataSource.create(item);

    if (item.tags.isNotEmpty) {
      await tagDataSource.incrementTagCount(item.tags, 1);
    }

    return itemId;
  }

  Future<Null> moveToTrash(String id) async {
    await validateDeletePrivileges(id);
    await _extensionServices.sendTrashingItem(id);
    await itemDataSource.setTrashStatus(id, true);
  }

  Future<Null> restoreFromTrash(String id) async {
    await validateUpdatePrivileges(id);
    await _extensionServices.sendRestoringItem(id);
    await itemDataSource.setTrashStatus(id, false);
  }

  @override
  Future<String> delete(String id) async {
    await validateDeletePrivileges(id);

    await _extensionServices.sendDeletingItem(id);

    final Option<Item> existingItem = await itemDataSource.getById(id);
    if (existingItem.isEmpty) throw new NotFoundException("Item $id not found");

    final String output = await super.delete(id);

    if (existingItem.first.tags.isNotEmpty) {
      await tagDataSource.incrementTagCount(existingItem.first.tags, -1);
    }

    try {
      final File file = new File(getOriginalFilePathForHash(id));
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
      _log.warning("Error while deleting full file", e, st);
    }
    try {
      final File file = new File(getThumbnailFilePathForHash(id));
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e, st) {
      _log.warning("Error while deleting thumbnail file", e, st);
    }

    return output;
  }

  Future<List<int>> generatePdfThumbnail(String originalFile) async {
    _log.fine("generatePdfThumbnail start");
    final Directory tempFolder =
        await Directory.systemTemp.createTemp("dartlery_imagemagick_output");
    final String tempfile = path.join(tempFolder.path, "thumbnail.png");
    try {
      String command = "convert";
      final List<String> args = <String>['${originalFile}[0]', tempfile];
      if (Platform.isWindows) {
        args.insert(0, command);
        command = "magick";
      }
      final ProcessResult result = await Process.run(command, args);
      if (result.exitCode != 0) {
        throw new Exception(
            "Error while generating PDF thumbnail: ${result.stderr
                .toString()}");
      }
      return await getFileData(tempfile);
    } finally {
      try {
        await tempFolder.delete(recursive: true);
      } catch (e, st) {
        _log.warning("Error while deleting PDF thumbnail temp file", e, st);
      }
      _log.fine("generatePdfThumbnail end");
    }
  }

  Future<List<int>> generatePdfMontage(String originalFile) async {
    _log.fine("generatePdfThumbnail start");
    final Directory tempFolder =
        await Directory.systemTemp.createTemp("dartlery_imagemagick_output");
    final String tempfile = path.join(tempFolder.path, "thumbnail.png");
    try {
      String command = "montage";
      final List<String> args = <String>[
        originalFile,
        '-density',
        '288',
        '-resize',
        '50%',
        '-mode',
        'Concatenate',
        '-tile',
        '6x',
        "-background",
        "'#000000'",
        tempfile
      ];
      if (Platform.isWindows) {
        args.insert(0, command);
        command = "magick";
      }

      final ProcessResult result = await Process.run(command, args);
      if (result.exitCode != 0) {
        throw new Exception("Error while generating PDF montage: ${result.stderr
                .toString()}");
      }
      return await getFileData(tempfile);
    } finally {
      try {
        await tempFolder.delete(recursive: true);
      } catch (e, st) {
        _log.warning("Error while deleting montage temp file", e, st);
      }
      _log.fine("generatePdfMontage end");
    }
  }

  Future<List<int>> generateFfmpegThumbnail(String originalFile) async {
    _log.fine("generateFfmpegThumbnail start");
    final Directory tempFolder =
        await Directory.systemTemp.createTemp("dartlery_ffempeg_output");
    final String tempfile = path.join(tempFolder.path, "thumbnail.png");
    try {
      final ProcessResult result = await Process.run("ffmpeg", <String>[
        '-i',
        originalFile,
        '-vf',
        "thumbnail",
        '-frames:v',
        '1',
        tempfile
      ]);
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
      _log.fine("generateFfmpegThumbnail end");
    }
  }

  @override
  Future<Item> getById(String uuid, {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateGetPrivileges();

    final Item output =
        await super.getById(uuid, bypassAuthentication: bypassAuthentication);

    return output;
  }

  Future<Null> getFfprobeData(Item item, String originalFile) async {
    _log.fine("getFfprobeData start");
    ProcessResult result = await Process.run(
        "ffprobe",
        <String>[
          '-i',
          originalFile,
          '-show_entries',
          'format=duration',
          '-v',
          'quiet',
          '-of',
          'csv=p=0'
        ],
        runInShell: true);
    if (result.exitCode != 0) {
      final String error = result.stderr.toString();
      _log.warning("Error while getting video duration: $error");
      item.errors.add("Error while getting video duration: $error");
    } else {
      final String durationString = result.stdout.toString().trim();
      try {
        final double durationDouble = double.parse(durationString);
        item.duration = (durationDouble * 1000).floor();
      } on FormatException catch (e, st) {
        item.errors.add("Could not interpret item duration: $durationString");
        _log.warning(
            "Could not interpret item duration: $durationString", e, st);
      }
    }
    result = await Process.run("ffprobe",
        <String>['-i', originalFile, '-show_streams', '-select_streams', 'v']);
    if (result.exitCode != 0) {
      final String error = result.stderr.toString();
      _log.warning("Error while getting video sream data: $error");
      item.errors.add("Error while getting video sream data: $error");
    } else {
      final String videoStreams = result.stdout.toString();
      if (videoStreams.contains("[STREAM]")) {
        if (_codecNameRegex.hasMatch(videoStreams)) {
          item.metadata["video_codec"] =
              _codecNameRegex.firstMatch(videoStreams).group(1);
          if (item.mime == MimeTypes.mkv) {
            if (item.metadata["video_codec"].contains("VP8") ||
                item.metadata["video_codec"].contains("VP9")) {
              item.mime = MimeTypes.webm;
            }
          }
        }

        if (_videoPixelFormatRegex.hasMatch(videoStreams)) {
          item.metadata["video_pixel_format"] =
              _videoPixelFormatRegex.firstMatch(videoStreams).group(1);
        }
        if (_videoFrameRateRegex.hasMatch(videoStreams)) {
          final Match m = _videoFrameRateRegex.firstMatch(videoStreams);
          final double a = double.parse(m.group(1));
          final double b = double.parse(m.group(2));
          String output = (a / b).toString();
          while (output.substring(output.length - 1, output.length) == "0") {
            output = output.substring(0, output.length - 1);
          }
          if (output.substring(output.length - 1, output.length) == ".") {
            output = output.substring(0, output.length - 1);
          }

          item.metadata["video_frame_rate"] = output;
        }
        if (_bitRateRegex.hasMatch(videoStreams)) {
          item.metadata["video_bit_rate"] =
              _bitRateRegex.firstMatch(videoStreams).group(1);
        }
      } else {
        _log.warning("No video stream data found");
        item.errors.add("No video stream data found");
      }
    }

    result = await Process.run("ffprobe",
        <String>['-i', originalFile, '-show_streams', '-select_streams', 'a']);
    if (result.exitCode != 0) {
      final String error = result.stderr.toString();
      _log.warning("Error while getting audio stream data: $error");
      item.errors.add("Error while getting audio stream data: $error");
    } else {
      final String audioStreams = result.stdout.toString();
      if (audioStreams.contains("[STREAM]")) {
        item.audio = true;
        if (_codecNameRegex.hasMatch(audioStreams)) {
          item.metadata["audio_codec"] =
              _codecNameRegex.firstMatch(audioStreams).group(1);
        }
        if (_audioSampleRateRegex.hasMatch(audioStreams)) {
          item.metadata["audio_sample_rate"] =
              _audioSampleRateRegex.firstMatch(audioStreams).group(1);
        }
        if (_bitRateRegex.hasMatch(audioStreams)) {
          item.metadata["audio_bit_rate"] =
              _bitRateRegex.firstMatch(audioStreams).group(1);
        }
        if (_audioChannelsRegex.hasMatch(audioStreams)) {
          item.metadata["audio_channels"] =
              _audioChannelsRegex.firstMatch(audioStreams).group(1);
        }
      } else {
        item.audio = false;
      }
    }
    _log.fine("getFfprobeData end");
  }

  Future<PaginatedIdData<Item>> getVisible(
      {int page: 0,
      int perPage: defaultPerPage,
      DateTime cutoffDate,
      bool inTrash: false}) async {
    if (page < 0) {
      throw new InvalidInputException("Page must be a non-negative number");
    }
    if (perPage < 0) {
      throw new InvalidInputException("Per-page must be a non-negative number");
    }
    await validateGetAllPrivileges();
    final PaginatedData<Item> output = await dataSource.getVisiblePaginated(
        this.currentUserId,
        page: page,
        perPage: perPage,
        cutoffDate: cutoffDate,
        inTrash: inTrash);

    await adjustAll(output.data);

    return output;
  }

  Future<PaginatedIdData<Item>> getInTrash(
      {int page: 0, int perPage: defaultPerPage, DateTime cutoffDate}) async {
    if (page < 0) {
      throw new InvalidInputException("Page must be a non-negative number");
    }
    if (perPage < 0) {
      throw new InvalidInputException("Per-page must be a non-negative number");
    }
    await validateGetPrivileges();

    final PaginatedData<Item> output = await dataSource.getVisiblePaginated(
        this.currentUserId,
        page: page,
        perPage: perPage,
        cutoffDate: cutoffDate,
        inTrash: true);
    await adjustAll(output.data);

    return output;
  }

  Future<Item> merge(String targetItemId, String sourceItemId,
      {bool bypassAuthentication: false, bool moveToTrash: true}) async {
    if (!bypassAuthentication) await validateUpdatePrivileges(targetItemId);
    if (!bypassAuthentication) await validateDeletePrivileges(sourceItemId);

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
    if (moveToTrash) {
      await this.moveToTrash(sourceItemId);
    } else {
      await delete(sourceItemId);
    }

    // TODO: Verify this handles the tag counts correctly, doesn't look right.
    final TagDiff diff =
        new TagDiff(targetItem.first.tags, sourceItem.first.tags);
    if (diff.both.isNotEmpty) {
      await tagDataSource.incrementTagCount(diff.both, -1);
    }

    final Item output = (await itemDataSource.getById(targetItemId)).first;
    await performAdjustments(output);
    return output;
  }

  Future<List<Item>> getRandom(
      {List<Tag> filterTags,
      int perPage: defaultPerRandomPage,
      bool imagesOnly: false}) async {
    await validateSearchPrivileges();

    if (filterTags != null) {
      filterTags = await _tagModel.handleTags(filterTags);
    }

    final List<Item> output = await itemDataSource.getVisibleRandom(
        this.currentUserId,
        perPage: perPage,
        filterTags: filterTags,
        imagesOnly: imagesOnly);

    await adjustAll(output);
    return output;
  }

  Future<PaginatedIdData<Item>> searchVisible(List<Tag> tags,
      {int page: 0,
      int perPage: defaultPerPage,
      DateTime cutoffDate,
      bool inTrash: false}) async {
    if (page < 0) {
      throw new InvalidInputException("Page must be a non-negative number");
    }
    if (perPage < 0) {
      throw new InvalidInputException("Per-page must be a non-negative number");
    }
    await validateSearchPrivileges();

    await _tagModel.handleTags(tags);

    final PaginatedData<Item> output = await dataSource.searchVisiblePaginated(
        this.currentUserId, tags,
        page: page, perPage: perPage, cutoffDate: cutoffDate, inTrash: inTrash);
    await adjustAll(output.data);

    return output;
  }

  @override
  Future<String> update(String id, Item item,
      {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateUpdatePrivileges(id);

    await _tagModel.handleTags(item.tags, createTags: true);

    final Option<Item> existingItem = await itemDataSource.getById(id);
    if (existingItem.isEmpty) throw new NotFoundException("Item $id not found");

    final String output = await super
        .update(id, item, bypassAuthentication: bypassAuthentication);

    final TagDiff diff = new TagDiff(existingItem.first.tags, item.tags);
    if (diff.onlyFirst.isNotEmpty) {
      await tagDataSource.incrementTagCount(diff.onlyFirst, -1);
    }
    if (diff.onlySecond.isNotEmpty) {
      await tagDataSource.incrementTagCount(diff.onlySecond, 1);
    }

    return output;
  }

  Future<Null> updateTags(String itemId, List<Tag> newTags,
      {bool bypassAuthentication: false}) async {
    if (!bypassAuthentication) await validateUpdatePrivileges(itemId);

    final Option<Item> existingItem = await itemDataSource.getById(itemId);
    if (existingItem.isEmpty)
      throw new NotFoundException("Item $itemId not found");

    await _tagModel.handleTags(newTags, createTags: true);
    await itemDataSource.updateTags(itemId, newTags);

    final TagDiff diff = new TagDiff(existingItem.first.tags, newTags);
    if (diff.onlyFirst.isNotEmpty) {
      await tagDataSource.incrementTagCount(diff.onlyFirst, -1);
    }
    if (diff.onlySecond.isNotEmpty) {
      await tagDataSource.incrementTagCount(diff.onlySecond, 1);
    }
  }

  @override
  Future<Null> validateFields(Item item, Map<String, String> fieldErrors,
      {String existingId: null}) async {
    //TODO: add dynamic field validation
    await super.validateFields(item, fieldErrors);

    if (isNullOrWhitespace(existingId)) {
      if ((item.fileData == null || item.fileData.length == 0) &&
          isNullOrWhitespace(item.filePath)) {
        fieldErrors["file"] = "Required";
      }
    }

    if (isNullOrWhitespace(item.fileName)) {
      fieldErrors["fileName"] = "Required";
    }

    if (item.tags != null) {
      // TODO: Get the error feedback to be able to handle positional feedback
      for (Tag tag in item.tags) {
        if (isNullOrWhitespace(tag.id)) {
          fieldErrors["id"] = "Tag name required";
        }
      }
    }
  }

  Future<File> _createAndSaveThumbnail(image.Image image, String hash) async {
    _log.fine("_createAndSaveThumbnail start");
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
      _log.fine("_createAndSaveThumbnail end");
    }

    return thumbnailFile;
  }

  Future<List<FileSystemEntity>> processItem(Item item) async {
    final List<FileSystemEntity> filesWritten = <FileSystemEntity>[];

    _log.fine("Getting MIME type");
    final String mime = await item.calculateMimeType();

    if (isNullOrWhitespace(mime)) {
      throw new InvalidInputException("Mime type of file is unknown");
    }

    _log.fine("MIME type: $mime");

    item.mime = mime;

    final String originalFile = getOriginalFilePathForHash(item.id);

    filesWritten.add(await item.writeFileData(originalFile));

    image.Image originalImage;
    if (MimeTypes.imageTypes.contains(mime)) {
      _log.fine("Is image MIME type");
      if (MimeTypes.animatableImageTypes.contains(mime)) {
        _log.fine("Is animatable image MIME type");
        try {
          _log.fine("Decoding animation");
          final image.Animation anim =
              image.decodeAnimation(await item.getFileDataSafely());
          _log.fine("Animation decoded");
          if (anim.length > 1) {
            _log.fine("Has more than one frame, marking as video");
            item.video = true;
            item.duration = 0;
            for (image.Image i in anim) {
              item.duration += i.duration;
            }
            _log.fine("Duration: ${item.duration}");
          }
          originalImage = anim[0];
        } catch (e, st) {
          // Not an animation
          _log.fine("Not an animation!", e, st);
          originalImage = await decodeImage(item);
        }
      } else {
        _log.fine("Decoding image");
        originalImage = await decodeImage(item);
        _log.fine("image decoded");
      }
      if (mime == MimeTypes.jpeg || mime == MimeTypes.tiff) {
        try {
          _log.fine("Reading exif data");
          final Map<String, IfdTag> data =
              await readExifFromFile(new File(originalFile));
          for (String key in data.keys) {
            item.metadata[key] = data[key].toString();
          }
          _log.fine("Done reading exif data", item.metadata);
        } catch (e, st) {
          _log.warning("Error while fetching exif data", e, st);
          item.errors.add("Error while fetching exif data: ${e.toString()}");
        }
      }
    } else if (MimeTypes.videoTypes.contains(mime) || mime == MimeTypes.swf) {
      try {
        _log.fine("Is video mime type");
        item.video = true;
        originalImage =
            image.decodePng(await generateFfmpegThumbnail(originalFile));
        await getFfprobeData(item, originalFile);
      } catch (e, st) {
        if (mime == MimeTypes.swf) {
          _log.warning("Error while genereting thumbnail of swf", e, st);
          item.errors
              .add("Error while genereting thumbnail of swf: ${e.toString()}");
        } else {
          rethrow;
        }
      }
    } else if (mime == MimeTypes.pdf) {
      originalImage = image.decodePng(await generatePdfMontage(originalFile));
    } else {
      throw new InvalidInputException("MIME type not supported: $mime");
    }
    if (originalImage != null) {
      item.height = originalImage.height;
      item.width = originalImage.width;

      if (MimeTypes.webFriendlyTypes.contains(mime)) {
        _log.fine("Web-friendly MIME type, using original file for display");
        //filesWritten.add(await new Link(getFullFilePathForHash(item.id))
        //.create(getOriginalFilePathForHash(item.id), recursive: true));
      } else {
        _log.fine(
            "Non-web-friendly MIME type, generating full-size image for display");
        filesWritten.add(await _writeBytes(getFullFilePathForHash(item.id),
            image.encodeJpg(originalImage, quality: jpegQuality),
            deleteExisting: true));
        _log.fine("Full-size image generated");
        item.fullFileAvailable = true;
      }

      try {
        if (mime == MimeTypes.pdf) {
          originalImage =
              image.decodePng(await generatePdfThumbnail(originalFile));
        }

        filesWritten.add(await _createAndSaveThumbnail(originalImage, item.id));
      } catch (e, st) {
        _log.warning("Error while generating thumbnail for ${item.id}", e, st);
        item.errors.add(
            "Error while generating thumbnail for ${item.id}: ${e.toString()}");
      }
    }

    return filesWritten;
  }

  Future<image.Image> decodeImage(Item item) async {
    // Some images fool the image library's method for identifying image types,
    // so we manually help it out with the two formats know to have issues.
    final List<int> fileData = await item.getFileDataSafely();
    switch (item.mime) {
      case MimeTypes.png:
        return image.decodePng(fileData);
      case MimeTypes.gif:
        return image.decodeGif(fileData);
      case MimeTypes.tiff:
        return image.decodeTiff(fileData);
      default:
        return image.decodeImage(fileData);
    }
  }

  Future<Null> _handleFileUpload(Item item) async {
    _log.fine("_handleFileUpload start");

    if (item.fileData == null) {
      if (isNullOrWhitespace(item.filePath))
        throw new Exception(("No file data or file path specified"));
    }

    _log.fine("Generating file hash...");
    item.id = await item.calculateHash();

    if (isNullOrWhitespace(item.id))
      throw new Exception("No hash generated for file data");

    _log.fine("File hash: ${item.id}");

    _log.fine("Checking if item already exists");
    if (await itemDataSource.existsById(item.id))
      throw new DuplicateItemException("Item ${item.id} already imported");

    item.length = await item.getDataLength();

    final List<FileSystemEntity> filesWritten = <FileSystemEntity>[];

    try {
      filesWritten.addAll(await processItem(item));
    } catch (e, st) {
      _log.severe(e, st);
      for (FileSystemEntity fse in filesWritten) {
        if (fse == null) continue;

        try {
          final bool exists = await fse.exists();
          if (exists) await fse.delete();
        } catch (e2, st) {
          _log.warning(e2, st);
        }
      }
      rethrow;
    } finally {
      _log.fine("_handleFileUpload end");
    }
  }

  Future<List<int>> _resizeImage(image.Image img,
      {int maxDimension: 300}) async {
    image.Image thumbnail;
    if (img.width < img.height) {
      thumbnail = image.copyResize(img, maxDimension, -1, image.AVERAGE);
    } else {
      final double newWidth = img.width * (maxDimension / img.height);

      thumbnail =
          image.copyResize(img, newWidth.floor(), maxDimension, image.AVERAGE);
    }
    return image.encodeJpg(thumbnail, quality: jpegQuality);
  }

  Future<File> _writeBytes(String path, List<int> bytes,
      {bool deleteExisting: false}) async {
    final File file = new File(path);
    bool fileExists = await file.exists();
    int size = 0;
    if (fileExists) {
      if (deleteExisting) {
        await file.delete();
        fileExists = file.existsSync();
      } else {
        size = file.lengthSync();
        if (size == 0) {
          file.deleteSync();
          fileExists = file.existsSync();
        }
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
    } else if (size != bytes.length) {
      throw new Exception("File already exists with a different size");
    } else {
      // Same size, we didn't write anything, we leave it alone
      return null;
    }
    return file;
  }
}
