import 'dart:html';
import 'dart:convert';
import 'package:polymer/polymer.dart';
import 'package:dartlery/client/client.dart';

@CustomTag('dartlery-tag-list')
class DartleryTagListElement extends PolymerElement {

  List tags = new ObservableList();
  
  DartleryTagListElement.created() : super.created()  {
    
    
  }


}