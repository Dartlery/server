import 'dart:async';
import 'dart:io';

import 'package:crypt/crypt.dart';
import 'package:crypto/crypto.dart';
import 'package:dartlery_shared/global.dart';
import 'package:mime/mime.dart';
import 'package:rpc/rpc.dart';

import 'src/media_mime_resolver.dart';

final MediaMimeResolver mediaMimeResolver = new MediaMimeResolver();

List<List<int>> convertMediaMessagesToIntLists(List<MediaMessage> input) {
  final List<List<int>> output = <List<int>>[];
  for (MediaMessage mm in input) {
    output.add(mm.bytes);
  }
  return output;
}

String generateHash(List<int> bytes) {
  if (bytes == null || bytes.length == 0)
    throw new InvalidInputException("Byte array cannot be null or empty");

  final Digest hash = sha256.convert(bytes);
  return hash.toString();
}

Future<List<int>> getFileData(String path) async {
  final File f = new File(path);
  if (!f.existsSync()) throw new Exception("File not found");
  RandomAccessFile raf;
  try {
    raf = await f.open();
    final int length = await raf.length();
    return await raf.read(length);
  } finally {
    if (raf != null) await raf.close();
  }
}

/// Performs clean-up techniques on readable IDs that have been received via the API.
///
/// Performs URI decoding, trims, and toLowerCases the string to ensure consistent readable ID formatting and matching.
String normalizeReadableId(String input) {
  if (input == null) throw new ArgumentError.notNull("input");

  String output = Uri.decodeQueryComponent(input);
  output = output.trim().toLowerCase();

  return output;
}
