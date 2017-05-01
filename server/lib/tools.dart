import 'package:rpc/rpc.dart';
import 'dart:async';
import 'dart:io';
import 'package:mime/mime.dart';
import 'src/media_mime_resolver.dart';

List<List<int>> convertMediaMessagesToIntLists(List<MediaMessage> input) {
  final List<List<int>> output = <List<int>>[];
  for (MediaMessage mm in input) {
    output.add(mm.bytes);
  }
  return output;
}

/// Performs clean-up techniques on readable IDs that have been received via the API.
///
/// Performs URI decoding, trims, and toLowerCases the string to ensure consistent readable ID formatting and matching.
String normalizeReadableId(String input) {
  if(input==null)
    throw new ArgumentError.notNull("input");

  String output = Uri.decodeQueryComponent(input);
  output = output.trim().toLowerCase();

  return output;
}

Future<List<int>> getFileData(String path) async {
  final File f = new File(path);
  if(!f.existsSync())
    throw new Exception("File not found");
  RandomAccessFile raf;
  try {
    raf = await f.open();
    final int length = await raf.length();
    return await raf.read(length);
  } finally {
    if(raf!=null)
      await raf.close();
  }

}

final MediaMimeResolver mediaMimeResolver = new MediaMimeResolver();