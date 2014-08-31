import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';


@CustomTag('dartlery-spinner')
class DartlerySpinnerElement extends PolymerElement {
 
  @observable String color = "";
  
  @observable int size = 50;
  
  DartlerySpinnerElement.created() : super.created()  {
  }
  

}