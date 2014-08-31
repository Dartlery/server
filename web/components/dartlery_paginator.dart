import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';

typedef void ChangePageEvent(int old_page, int new_page);

@CustomTag('dartlery-paginator')
class DartleryPaginatorElement extends PolymerElement {
  static const String DEFAULT_SEARCH_TEXT = "Search...";
  
  final StreamController<int> _changePageController = new StreamController<int>();
  Stream<int> get onPageChange => _changePageController.stream;
  
  @observable String currentPage = "1";
  @observable int lastPage = 1;
  
  int previousPage = 1;

  int get currentPageInt {
    return int.parse(currentPage);
  }
 
  DartleryPaginatorElement.created() : super.created()  {
  }
  
  void setPageRanges(int currentPage, int lastPage) {
    this.lastPage = lastPage;
    this.currentPage = currentPage.toString();
    this.previousPage = currentPageInt;
  }
  
  void changeToPage(int page) {
    if(this.previousPage!=page) {
      this.previousPage = page;
      this._changePageController.add(page);
    }
  }
  

  void pageSliderChange(Event e, var detail, InputElement target) {
    changeToPage(this.currentPageInt);
  }



  void pageSliderMouseWheel(WheelEvent e, var detail, InputElement target) {
    if (e.wheelDeltaY > 0) {
      if (this.currentPageInt < this.lastPage) {
        this.currentPage = (this.currentPageInt + 1).toString();
      }
    } else {
      if (this.currentPageInt > 1) {
        this.currentPage = (this.currentPageInt - 1).toString();
      }
    }
    pageSliderChange(e, detail, target);
  }

}