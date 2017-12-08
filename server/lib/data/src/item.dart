import 'dart:io';
import 'dart:async';
import 'package:rpc/rpc.dart';
import 'package:logging/logging.dart';
import 'package:server/data/data.dart';
import 'tag.dart';
import 'package:server/tools.dart';
import 'package:server/data_sources/data_sources.dart';

@ApiMessage(includeSuper: true)
class Item extends AIdData {
  static final Logger _log = new Logger('Item');

  static const String uploadedIndexName = "UploadedIndex";
  static const String itemTagsIndex = "ItemTagsIndex";

  @ApiProperty(ignore: true)

  @DbIndex(itemTagsIndex, order: 0)
  @DbIndex(uploadedIndexName, order: 0)
  bool inTrash = false;


  String extension;
  @ApiProperty(ignore: true)
  String filePath;
  List<int> fileData;
  String fileName;
  String downloadName;
  @ApiProperty(format: "uint64")
  int length;
  int height;
  int width;
  int duration;
  bool video = false;
  bool audio = false;
  Map<String, String> metadata = <String, String>{};
  String mime;
  String source;

  @DbIndex(itemTagsIndex, order: 1)
  @DbLink()
  List<Tag> tags = <Tag>[];

  @DbIndex(itemTagsIndex, order: 2, ascending: false)
  @DbIndex(uploadedIndexName, order: 1, ascending: false)
  DateTime uploaded;

  String uploader;
  List<String> errors = <String>[];
  bool fullFileAvailable = false;


  Item();

  Future<String> calculateMimeType() async {
    if (fileData == null) {
      return await mediaMimeResolver.getMimeTypeForFile(filePath);
    } else {
      return mediaMimeResolver.getMimeType(fileData);
    }
  }

  Future<String> calculateHash() async {
    if (fileData == null) {
      return await generateHashForFile(filePath);
    } else {
      return generateHash(fileData);
    }
  }

  Future<int> getDataLength() async {
    if (fileData == null) {
      return await new File(filePath).length();
    } else {
      return fileData.length;
    }
  }

  Future<List<int>> getFileDataSafely() async {
    if (fileData != null) {
      return fileData;
    } else {
      return await getFileData(filePath);
    }
  }

  Future<File> writeFileData(String path, {bool deleteExisting: false}) async {
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
    int newLength;
    if (fileData == null) {
      newLength = await new File(filePath).length();
    } else {
      newLength = fileData.length;
    }

    if (!fileExists) {
      await file.create(recursive: true);
      if (fileData == null) {
        final File sourceFile = new File(filePath);
        await sourceFile.copy(path);
      } else {
        final RandomAccessFile imageRaf =
            await file.open(mode: FileMode.WRITE_ONLY);
        try {
          _log.fine("Writing to ${file.path}");
          await imageRaf.writeFrom(fileData);
        } finally {
          try {
            await imageRaf.close();
          } catch (e2, st) {
            _log.warning("Error while closing file object", e2, st);
          }
        }
      }
    } else if (size != newLength) {
      throw new Exception("File already exists with a different size");
    } else {
      // Same size, we didn't write anything, we leave it alone
      return null;
    }
    return file;
  }
}
