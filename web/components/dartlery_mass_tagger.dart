import 'dart:html';
import 'dart:convert';
import 'package:polymer/polymer.dart';
import 'package:dartlery/client/client.dart';

@CustomTag('dartlery-mass-tagger')
class DartleryMassTaggerElement extends PolymerElement {
  
  @observable final List<String> tags = new ObservableList();
  
  DartleryMassTaggerElement.created() : super.created();

  void clearTags() {
    tags.clear();
  }
  
  void addAllTags(Iterable<String> tags) {
    for(String tag in tags) {
      if(tag!=null&&tag!="") {
        this.addTag(tag);
      }
    }
  }

  void addTag(String tag) {
    if(!this.tags.contains(tag)) {
      this.tags.add(tag);
    }
  }

}