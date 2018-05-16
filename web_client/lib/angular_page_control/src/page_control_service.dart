import 'dart:async';

import 'package:angular/core.dart';
import 'package:uuid/uuid.dart';
import 'page_action.dart';
import 'pagination_info.dart';
import 'page_message.dart';

@Injectable()
class PageControlService {
  PaginationInfo currentPaginationInfo;

  final StreamController<PaginationInfo> _paginationController =
      new StreamController<PaginationInfo>.broadcast();

  final StreamController<MessageEventArgs> _messageController =
      new StreamController<MessageEventArgs>.broadcast();

  final StreamController<ResponseEventArgs> _responseController =
      new StreamController<ResponseEventArgs>.broadcast();

  final StreamController<String> _pageTitleController =
      new StreamController<String>.broadcast();

  final StreamController<PageActionEventArgs> _pageActionController =
      new StreamController<PageActionEventArgs>.broadcast();

  final StreamController<List<PageAction>> _availablePageActionController =
      new StreamController<List<PageAction>>.broadcast();

  final StreamController<ProgressEventArgs> _progressController =
      new StreamController<ProgressEventArgs>();

  Stream<ProgressEventArgs> get progressChanged => _progressController.stream;

  Stream<PageActionEventArgs> get pageActionRequested =>
      _pageActionController.stream;

  Stream<String> get pageTitleChanged => _pageTitleController.stream;

  Stream<MessageEventArgs> get messageSent => _messageController.stream;

  Stream<ResponseEventArgs> get responseSent => _responseController.stream;

  Stream<List<PageAction>> get availablePageActionsSet =>
      _availablePageActionController.stream;

  void requestPageAction(PageActionEventArgs e) {
    switch (e.action) {
      case PageAction.search:
        throw new Exception("Use the search() function");
      default:
        this._pageActionController.add(e);
        break;
    }
  }

  void sendResponse(ResponseEventArgs e) {
    this._responseController.add(e);
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

  String sendMessage(PageMessage message) {
    Uuid uuid = new Uuid();
    String id = uuid.v1();
    _messageController.add(new MessageEventArgs(message, id));
    return id;
  }

  void clearProgress() {
    _progressController.add(new ProgressEventArgs());
  }

  void setIndeterminateProgress() {
    _progressController.add(new ProgressEventArgs()
      ..show = true
      ..indeterminate = true);
  }

  void setProgress(int value, {int min = 0, int max = 100}) {
    _progressController.add(new ProgressEventArgs()
      ..show = true
      ..value = value
      ..min = min
      ..max = max);
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
  final PageMessage message;
  final String id;
  MessageEventArgs(this.message, this.id);
}

class ResponseEventArgs<T> {
  final PageMessage originalMessage;
  final String id;
  final T value;

  ResponseEventArgs(this.originalMessage, this.id, this.value);
}

class PageActionEventArgs {
  final PageAction action;
  final dynamic value;

  PageActionEventArgs(this.action, {this.value = null});
}

class ProgressEventArgs {
  bool show = false;
  bool indeterminate = false;
  int value = 0;
  int min = 0;
  int max = 100;
}
