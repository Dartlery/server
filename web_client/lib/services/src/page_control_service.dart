import 'dart:async';

import 'package:angular2/core.dart';
import 'package:dartlery/data/data.dart';
import 'page_action.dart';

@Injectable()
class PageControlService {
  PaginationInfo currentPaginationInfo;

  final StreamController<PaginationInfo> _paginationController =
      new StreamController<PaginationInfo>.broadcast();

  final StreamController<MessageEventArgs> _messageController =
      new StreamController<MessageEventArgs>.broadcast();

  final StreamController<String> _pageTitleController =
      new StreamController<String>.broadcast();

  final StreamController<PageAction> _pageActionController =
      new StreamController<PageAction>.broadcast();

  final StreamController<List<PageAction>> _availablePageActionController =
      new StreamController<List<PageAction>>.broadcast();

  final StreamController<ProgressEventArgs> _progressController = new StreamController<ProgressEventArgs>();

  Stream<ProgressEventArgs> get progressChanged => _progressController.stream;

  Stream<PageAction> get pageActionRequested => _pageActionController.stream;

  Stream<String> get pageTitleChanged => _pageTitleController.stream;

  Stream<MessageEventArgs> get messageSent => _messageController.stream;

  Stream<List<PageAction>> get availablePageActionsSet =>
      _availablePageActionController.stream;

  void requestPageAction(PageAction action) {
    switch (action) {
      case PageAction.search:
        throw new Exception("Use the search() function");
      default:
        this._pageActionController.add(action);
        break;
    }
  }

  Stream<PaginationInfo> get paginationChanged => _paginationController.stream;

  String currentQuery = "";

  final StreamController<String> _searchController =
      new StreamController<String>.broadcast();

  Stream<String> get searchChanged => _searchController.stream;

  void clearPaginationInfo() {
    setPaginationInfo(new PaginationInfo());
  }

  void clearSearch() {
    search("");
  }

  void reset() {
    clearPaginationInfo();
    clearSearch();
    clearPageTitle();
    clearAvailablePageActions();
  }

  void clearAvailablePageActions() {
    setAvailablePageActions(<PageAction>[]);
  }

  void setAvailablePageActions(List<PageAction> actions) {
    _availablePageActionController.add(actions);
  }

  void search(String query) {
    this.currentQuery = query;
    _searchController.add(query);
  }

  void setPaginationInfo(PaginationInfo info) {
    this.currentPaginationInfo = info;
    _paginationController.add(info);
  }

  void setPageTitle(String title) {
    _pageTitleController.add(title);
  }

  void clearPageTitle() {
    setPageTitle("");
  }

  void sendMessage(String title, String message) {
    _messageController.add(new MessageEventArgs(title, message));
  }

  void clearProgress() {
    _progressController.add(new ProgressEventArgs());
  }

  void setIndeterminateProgress() {
    _progressController.add(new ProgressEventArgs()..show=true..indeterminate=true);

  }

  void setProgress(int value, {int min = 0, int max = 100}) {
    _progressController.add(new ProgressEventArgs()..show=true..value=value..min=min..max=max);
  }

//  Future<Null> performAsyncProgressLoop<T>(List<T> items, Future<dynamic> callback(T item), {bool depleting=false}) async {
//    int i = 1;
//    final int total = items.length;
//    setProgress(0,max: total);
//    if(depleting) {
//      while(items.length>0) {
//
//      }
//    } else {
//      for(T item in items) {
//        await callback(item);
//        setProgress(1,max: total);
//        i++;
//      }
//    }
//
//  }
}

class MessageEventArgs {
  final String title;
  final String message;
  MessageEventArgs(this.title, this.message);
}

class ProgressEventArgs {
  bool show = false;
  bool indeterminate= false;
  int value = 0;
  int min = 0;
  int max = 100;
}