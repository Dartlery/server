import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';
import 'package:dartlery/client/client.dart';
import 'package:rest_client/rest_client.dart';

import 'dartlery_mass_tagger.dart';

@CustomTag('dartlery-gallery')
class DartleryGalleryElement extends PolymerElement {
  static final Logger _log = new Logger('DartleryGalleryElement');

  static const String _CONTENT_RANGE_REGEXP_STRING = r"([^ ]+) (\d+)-(\d+)/(\d+)";
  static final RegExp _CONTENT_RANGE_REGEXP = new RegExp(_CONTENT_RANGE_REGEXP_STRING);

  final List images = new ObservableList();
  final List pages = new ObservableList();

  final List<String> currentSearchArgs = new List<String>();
  final List<String> currentSearchTags = new List<String>();
  final List<String> currentInclusiveSearchTags = new List<String>();
  final List<String> currentExclusiveSearchTags = new List<String>();

  DartleryMassTaggerElement tagger;
  
  bool _linksDisabled = true;
  
  bool _loaded = false;

  int _filesPerPage = 30;

  dynamic paginator;

  Element get _ele {
    return $["gallery"];
  }

  DartleryGalleryElement.created() : super.created() {
    //loadImages();
    paginator = $["paginator"];
    tagger = $["tagger"];
    paginator.onPageChange.listen((e) {
      window.location.hash = getCurrentLink() + "page=" + e.toString();
    });
  }

  String get currentSearchString {
    return currentSearchArgs.join(" ");
  }


  void setSearchArrays(String search) {
    currentSearchArgs.clear();
    currentSearchTags.clear();
    currentInclusiveSearchTags.clear();
    currentExclusiveSearchTags.clear();
    currentSearchArgs.addAll(search.trim().split(" "));
    
    for(String arg in currentSearchArgs) {
      if(arg.startsWith("-")) {
        currentExclusiveSearchTags.add(arg.substring(1));
        currentSearchTags.add(arg.substring(1));
      } else{
        currentInclusiveSearchTags.add(arg);
        currentSearchTags.add(arg);
        
      }
    }
  }

  Future search(String search, [int page = 1]) {
    setSearchArrays(search);
    return loadImages(page);
  }

  Future refresh() {
    return new Future(() {
      return loadImages(paginator.currentPageInt);
    });
  }

  Future loadImages(int page) {
    _loaded = false;
    $["spinner"].style.display = "block";
    
    Completer c = new Completer();
    clearErrorOutput();
    StringBuffer url = new StringBuffer();
    url.write(SERVER_ADDRESS + "files/?sort=-id");
    if (currentSearchArgs.length > 0) {
      url.write("&search=${this.currentSearchString}");
    }

    HttpRequest request = new HttpRequest();

    _log.info("Getting images from ${url.toString()}");

    request.open(HttpMethod.GET, url.toString());

    int start = (page - 1) * _filesPerPage;
    int end = start + _filesPerPage - 1;
    request.setRequestHeader(HttpHeaders.RANGE, "files=${start}-${end}");

    request.onError.listen((e) {
      setErrorOutput(e.toString());
    });

    request.onLoad.listen((e) {
      if (request.readyState != HttpRequest.DONE) {
        return;
      }

      Map data = JSON.decode(request.responseText);

      if (data.containsKey("message")) {
        setErrorOutput("(${request.status.toString()}) ${request.statusText}: ${data['message']}");
        return;
      }

      this.images.clear();
      this.tagger.clearTags();

      if (data["files"] != null && data["files"].length > 0) {
        for (Map file in data["files"]) {
          addImage(file);
        }
      } else {
        setErrorOutput("No files found");
      }

      String response = request.getResponseHeader("Content-Range");
      if (request.responseHeaders.containsKey("content-range")) {
        if (_CONTENT_RANGE_REGEXP.hasMatch(request.responseHeaders["content-range"])) {
          Match m = _CONTENT_RANGE_REGEXP.firstMatch(request.responseHeaders["content-range"]);
          start = int.parse(m.group(2));
          end = int.parse(m.group(3));
          int total = int.parse(m.group(4));

          //this._filesPerPage = end - start+ 1;

          int currentPage = (start / this._filesPerPage).floor() + 1;
          int lastPage = (total / this._filesPerPage).floor() + 1;

          paginator.setPageRanges(currentPage, lastPage);
          
          if (lastPage > 1) {

            //            StringBuffer paginations = new StringBuffer();
            //
            //
            //            int start_page;
            //            int last_page;
            //
            //            if(_currentPage<=5) {
            //              start_page = 1;
            //            } else if(_currentPage+6>=_currentMaxPages) {
            //              start_page = _currentMaxPages - 10;
            //            } else {
            //              start_page = _currentPage - 5;
            //            }
            //
            //            last_page = start_page + 10;
            //            int i = start_page;
            //
            //            if(_currentPage==1) {
            //              paginations.write("<< < ");
            //            } else {
            //              paginations.write("<a href='${link.toString()}page=1'><<</a> ");
            //              paginations.write("<a href='${link.toString()}page=${(_currentPage-1).toString()}'><</a> ");
            //            }
            //
            //            while(i <= _currentMaxPages && i <= last_page) {
            //              if(i ==_currentPage) {
            //                paginations.write("<b>${i.toString()}</b> ");
            //              } else {
            //                paginations.write("<a href='${link.toString()}page=${i.toString()}'>${i.toString()}</a> ");
            //              }
            //              i++;
            //            }
            //
            //            if(_currentPage==_currentMaxPages) {
            //              paginations.write(" > >>");
            //            } else {
            //              paginations.write("<a href='${link.toString()}page=${(_currentPage+1).toString()}'>></a> ");
            //              paginations.write("<a href='${link.toString()}page=${_currentMaxPages.toString()}'>>></a> ");
            //            }
            //
            //            $["paginator"].innerHtml = paginations.toString();
            paginator.style.display = "block";
          } else {
            paginator.style.display = "none";
          }
        }
      } else {
        paginator.style.display = "none";
      }
      _loaded = true;
      $["spinner"].style.display = "none";
      this._ele.style.display = "block";
      c.complete();
    });
    request.send();
    return c.future;
  }

  String getCurrentLink() {
    StringBuffer link = new StringBuffer();
    link.write("#files?");
    if (currentSearchArgs.length > 0) {
      link.write("search=${this.currentSearchString}&");
    }
    return link.toString();
  }

  String adjustSearch(String tag, bool add) {
    StringBuffer output = new StringBuffer();
    for (String item in this.currentSearchArgs) {
      if (item == tag || (item.startsWith("-") && item.substring(1) == tag)) {

      } else {
        output.write("${item} ");
      }
    }
    if (!add) {
      output.write("-");
    }
    output.write("${tag}");
    return output.toString();
  }
  String removeSearch(String tag) {
    StringBuffer output = new StringBuffer();
    for (String item in this.currentSearchArgs) {
      if (item == tag) {

      } else {
        output.write("${item} ");
      }
    }
    return output.toString();
  }

  void addImage(Map image_data) {
    this.images.add(image_data);
    if(image_data.containsKey("tags")) {
      this.tagger.addAllTags(image_data["tags"]);
    }
  }


  void hide() {
    this._ele.style.display = "none";
  }

  void show() {
    if (!_loaded) {
      loadImages(1);
    }
    this._ele.style.display = "block";
  }

  void thumbnailClicked(Event e, var detail, Node target) {
    if(this._linksDisabled) {
      e.preventDefault();
    }
  }
  
}
