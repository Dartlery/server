import 'dart:html';
import 'package:polymer/polymer.dart' as polymer;
import 'package:logging/logging.dart';
import 'package:dartlery/client/client.dart';

var gallery;
var viewer;
var navbar;
void main() {
  
  Logger.root.level = Level.CONFIG;
  Logger.root.onRecord.listen(RecordLog);
  
  //Debug debug = new Debug();

  polymer.initPolymer();
  
  navbar = document.getElementById("navbar");
  gallery = document.getElementById("gallery");
  viewer = document.getElementById("viewer");
  
  
  window.onHashChange.listen((HashChangeEvent e) {
    processHash();
  });

  
  
  window.onPopState.listen((PopStateEvent e) {
    //Do stuff
  });
  
  processHash();

}

void RecordLog(LogRecord rec) {
  print('${rec.time}: ${rec.level.name}: (${rec.loggerName}) ${rec.message}');
  if(rec.stackTrace!=null) {
    print('${rec.time}: ${rec.level.name}: (${rec.loggerName}) ${rec.stackTrace.toString()}');
  }
}

const String _HASH_REGEX_STRING = "";
final RegExp _HASH_REGEX = new RegExp(_HASH_REGEX_STRING);

void processHash() {
  List path = new List();
  if(window.location.hash!="") {
    path = window.location.hash.substring(1).split("/");
  }
  Map args = new Map();
  if(path.length>0&&path[path.length-1].contains("?")) {
    List tmp = path[path.length-1].split("?");
    path[path.length-1] = tmp[0];
    if(tmp.length>1) {
      tmp = tmp[1].split("&");
      for(String pair in tmp) {
        if(pair!=null&&pair!="") {
          List tmp2 = pair.split("=");
          if(tmp2.length>1) {
            args[tmp2[0]] = tmp2[1];
          }
        }
      }
    }
  }
  
  if(path.length>0&&path[0]!="") {
    switch(path[0]) { // Top-level page
      case "files":
        if(path.length>1) {
          gallery.hide();
          viewer.displayFile(path[1]);
        } else {
          String search = "";
          int page = 1;
          if(args.containsKey("search")) {
            search = Uri.decodeFull(args["search"]);
          }
          if(args.containsKey("page")) {
            page = int.parse(args["page"]);
          }
          navbar.setSearchText(search);
          viewer.hide();
          gallery.search(search,page).then((_) {
            gallery.show();
          });
        }
        break;
      default:
        throw new Exception("${path[0]} not supported");
    }
  } else {
    // Default view
    viewer.hide();
    gallery.search("").then((_) {
      gallery.show();
    });
  }
  
}