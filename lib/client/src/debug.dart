part of client;

class Debug {
  static final DivElement _ele  = new DivElement();
  
  Debug() {
    Debug._ele.className = "debug";
    document.body.append(_ele);

  }
  
  static void addLine(String message) {
    
    DivElement ele = new DivElement();
    ele.innerHtml = message;
    Debug._ele.append(ele);
  }
}