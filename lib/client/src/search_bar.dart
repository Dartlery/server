part of client;

class SearchBar {
  DivElement _ele = new DivElement();
  
  SearchBar() {
    _ele.className = "search";
    document.body.append(_ele);
  }
}