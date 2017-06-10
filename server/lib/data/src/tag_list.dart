import 'dart:convert';
import 'package:dartlery/data/data.dart';

class TagList extends Iterable<Tag> {
  final List<Tag> _list = <Tag>[];

  TagList();

  TagList.from(Iterable<Tag> input) {
    for (Tag t in input) {
      this.add(t);
    }
  }

  TagList.fromJson(String json) {
    final JsonDecoder decode = new JsonDecoder();
    final dynamic data = decode.convert(json);
    if (!(data is List)) {
      throw new ArgumentError.value(json, "json", "JSON list expected");
    }
    final List tagData = data;
    for (dynamic subData in tagData) {
      if (!(subData is Map)) {
        throw new ArgumentError.value(
            json, "json", "Non-map entry in list encountered");
      }
      final Map tagSubData = subData;
      final Tag tag = new Tag();
      tag.id = tagSubData["id"];
      if (tagSubData.containsKey("category")) {
        tag.category = tagSubData["category"];
      }
      this.add(tag);
    }
  }

  @override
  Iterator<Tag> get iterator => _list.iterator;

  void clear() => _list.clear();

  void addAll(Iterable<Tag> tags) {
    for (Tag t in tags) {
      add(t);
    }
  }

  void add(Tag tag) {
    if (indexOf(tag) != -1) return;
    _list.add(tag);
  }

  void remove(Tag tag) {
    final int i = indexOf(tag);
    if (i == -1) return;
    _list.removeAt(i);
  }

  int indexOf(Tag tag) {
    for (int i = 0; i < _list.length; i++) {
      final Tag t = _list[i];
      if (tag.equals(t)) {
        return i;
      }
    }
    return -1;
  }

  @override
  bool contains(Tag t) => indexOf(t) != -1;
}

class TagDiff {
  final List<Tag> different = <Tag>[];
  final List<Tag> onlyFirst = <Tag>[];
  final List<Tag> onlySecond = <Tag>[];
  final List<Tag> both = <Tag>[];
  TagDiff(List<Tag> a, List<Tag> b) {
    for (Tag ta in a) {
      bool found = false;
      for (Tag tb in b) {
        if (ta == tb) {
          found = true;
          break;
        }
      }
      if (!found) {
        different.add(ta);
        onlyFirst.add(ta);
      } else {
        both.add(ta);
      }
    }

    for (Tag tb in b) {
      bool found = false;
      for (Tag ta in a) {
        if (ta == tb) {
          found = true;
          break;
        }
      }
      if (!found) {
        onlySecond.add(tb);
        different.add(tb);
      }
    }
  }
}
