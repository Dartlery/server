import 'dart:html';
import 'dart:convert';
import 'package:polymer/polymer.dart';
import 'package:dartlery/client/client.dart';

@CustomTag('dartlery-viewer')
class DartleryViewerElement extends PolymerElement {
  
  @observable String id = "-1";
  @observable String imageSource = "-1";
  @observable String tag_string = "";
  
  final List tags = new ObservableList();
  
    
  Element get _ele {
    return $["viewer"];
  }

  DartleryViewerElement.created() : super.created()  {
    
    
  }

  void displayFile(String id) {
    HttpRequest.getString("${SERVER_ADDRESS}files/${id}").then((response) {
      Map data = JSON.decode(response);
      if(data["files"]!=null) {
        for(Map file in data["files"]) {
          _showImageData(file);
        }
      }
    }).then((_) {
      this.id = id;
      this.show();
    });
  }
  
  void _showImageData(Map data) {
    List tags = data["tags"];
    this.tag_string = tags.join(" ");
    this.tags.clear();
    this.tags.addAll(tags);
    
    this.imageSource = data["file"];
  }
 
  void saveClick(Event e, var detail, Node target) {
    List data = new List();
    Map file = new Map();
    data.add(file);
    HttpRequest request = new HttpRequest();
    
    request.onReadyStateChange.listen((e) {
      if(request.readyState == HttpRequest.DONE) {
        Debug.addLine(request.response.toString());
      }
    });
    
    file["id"] = this.id;
    file["tags"] = this.tag_string.split(" ");
    
    request.open("POST", SERVER_ADDRESS + "files/", async:false);
    request.setRequestHeader("Content-Type",'application/json');
    request.send(JSON.encode(data));

  }
  
  void hide() {
    this.shadowRoot.host.style.display = "none";
  }
  
  void show() {
    this.shadowRoot.host.style.display = "block";
  }


}