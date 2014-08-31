library client;

import 'dart:html';
import 'dart:collection';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:polymer/polymer.dart';
import 'package:mime/mime.dart' as mime;
import 'package:crypto/crypto.dart' as crypto;


part 'src/debug.dart';

part 'src/tagging.dart';

part 'src/gallery_file.dart';
part 'src/search_bar.dart';

part 'src/upload.dart';

const String SERVER_ADDRESS = "http://localhost:8888/";


void viewFile(String id) {
  window.location.hash = "files=${id}";
}

void searchFor(String query) {
  window.location.hash = "#files?search=${query.trim()}";
}

void clearErrorOutput() {
  setErrorOutput("");
}

void setErrorOutput(String message) {
  document.getElementById("error_output").innerHtml = message;
}
