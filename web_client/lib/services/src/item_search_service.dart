import 'dart:async';
import 'package:angular2/angular2.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/api/api.dart';
import 'api_service.dart';

@Injectable()
class ItemSearchService {
  // TODO: Make searching persistent
  final ApiService _api;

  ItemSearchService(this._api);

  final TagList _tags = new TagList();
  DateTime _dateEnd;
  DateTime _dateStart;

  int _totalPages = 0;
  PaginatedResponse _response;

  final Map<int,List<String>> _results = new Map<int,List<String>>();

  Future<PaginatedResponse> performSearch({int page: 0}) async {
    PaginatedResponse response;
    if(_tags.isEmpty)
      response = await _api.items.getVisibleIds( page: page);
    else {
      final ItemSearchRequest request = new ItemSearchRequest();
      request.tags = _tags.toListOfTags();
      request.page = page;
      response = await _api.items.searchVisible(request);
    }
    _response = response;
    _results[page] = response.items;
    _totalPages = response.totalPages;
    return response;
  }

  void clear() {
    _response = null;
    _results.clear();
    _totalPages = 0;
  }

  void clearTags() {
    if(_tags.length>0) {
      _tags.clear();
      clear();
    }
  }

  void setTags(TagList tags) {
    if(!this._tags.compare(tags)) {
      clear();
      this._tags.clear();
      this._tags.addTagList(tags);
    }
  }

  Future<String> _getNextPageForItem(String item, int currentPage) async {
    final PaginatedResponse response = await performSearch(page: currentPage+1);
    if(response.items.isNotEmpty) {
      if(response.items.contains(item)) {
        final int i = response.items.indexOf(item);
        if(i==response.items.length-1) {
          if(currentPage<_totalPages) {
            return await _getNextPageForItem(item, currentPage + 1);
          }
        } else {
          return response.items[i+1];
        }
      } else {
        return response.items.first;
      }
    }
    return null;
  }

  Future<String> getNextItem(String item) async {
    for(int page in _results.keys) {
      if(_results[page].contains(item)) {
        final List<String> pageResults = _results[page];
        int i = pageResults.indexOf(item);
        if(i==pageResults.length-1) {
          if(_results.containsKey(page+1)&&_results[page+1].isNotEmpty) {
            return _results[page+1].first;
          } else if(page+1<=_totalPages) {
            return await _getNextPageForItem(item, page);
          }
        } else {
          return pageResults[i+1];
        }
      }
    }
    return null;
  }


  Future<String> _getPreviousPageForItem(String item, int currentPage) async {
    if(currentPage==0)
      return null;
    final PaginatedResponse response = await performSearch(page: currentPage-1);
    if(response.items.isNotEmpty) {
      if(response.items.contains(item)) {
        final int i = response.items.indexOf(item);
        if(i==0) {
          if(currentPage>0) {
            return await _getPreviousPageForItem(item, currentPage - 1);
          }
        } else {
          return response.items[i-1];
        }
      } else {
        return response.items.last;
      }
    }
    return null;
  }
  Future<String> getPreviousItem(String item) async {
    for(int page in _results.keys) {
      if(_results[page].contains(item)) {
        final List<String> pageResults = _results[page];
        final int i = pageResults.indexOf(item);
        if(i==0) {
          if(_results.containsKey(page-1)) {
            return _results[page-1].last;
          } else if(page>0) {
            return await _getPreviousPageForItem(item, page);
          }
        } else {
          return pageResults[i-1];
        }
      }
    }
    return null;
  }

}