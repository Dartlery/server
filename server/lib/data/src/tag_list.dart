import 'dart:convert';
import 'package:dartlery/data/data.dart';
import 'package:dartlery_shared/global.dart';

class TagList extends Iterable<Tag> {
  final List<Tag> _list = <Tag>[];

  TagList();

  TagList.from(Iterable<Tag> input) {
    for (Tag t in input) {
      this.add(t);
    }
  }

  TagList.fromJson(String json) {
    this.addAll(createTagListFromJson(json,
        (String name, String category) => new Tag.withValues(name, category)));
  }
  String toJson() => tagListToJson(this);

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
  bool contains(dynamic t) => indexOf(t) != -1;
}

class TagDiff extends Diff<Tag> {
  TagDiff(List<Tag> a, List<Tag> b) : super(a, b);
}
