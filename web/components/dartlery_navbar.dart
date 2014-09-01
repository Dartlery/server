import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';

import 'package:dartlery/client/client.dart';

@CustomTag('dartlery-navbar')
class DartleryNavbarElement extends PolymerElement {

  final List uploads = new ObservableList();

  DartleryNavbarElement.created() : super.created() {
  }


  void setSearchText(String text) {
    $["searchInput"].value = text;
  }

  void searchKeyPress(KeyboardEvent e, var detail, InputElement target) {
    if (e.charCode == 13) {
      searchFor(target.value.trim());
    }
  }

  void taggerClick(Event e, var detail, Node target) {
    //?

  }


  void uploadClick(Event e, var detail, Node target) {
    InputElement uploader = $["file_picker"];
    uploader.click();
  }

  void filePickerChange(Event e, var detail, Node target) {
    InputElement uploader = $["file_picker"];
    if (uploader.files.length == 0) {
      return;
    }
    List<File> files = uploader.files.toList();
    Future.forEach(files, (File file) {
      bool not_found = true;
//      for(Upload up in this.uploads) {
//        if(up.filePath==file.toString()) {
//          not_found = false;
//        }
//      }
      if (not_found) {
        Upload up = new Upload(file);
        this.uploads.add(up);
        if (uploads.length == 1) {
          up.startUpload().then(_uploadComplete);
        }
      }
    });

    uploader.value = "";
  }

  void _uploadComplete(upload) {
    this.uploads.remove(upload);
    if (this.uploads.length > 0) {
      Upload next = this.uploads[0];
      next.startUpload().then(_uploadComplete);
    } else {
      dynamic gal = document.getElementById("gallery");
      gal.refresh();
    }
  }

}
