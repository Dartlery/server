import 'package:dartlery/data/data.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery/api/api.dart';
import 'dart:html';

class TagList extends Iterable<TagWrapper> {
  final List<TagWrapper> _list = <TagWrapper>[];

  TagList();

  TagList.from(Iterable<TagWrapper> input) {
    for(TagWrapper t in input) {
      this.add(t);
    }
  }

  TagList.fromQueryString(String query) {
    final Iterable<Tag> tags =  query.split(tagSeparator).map((String tagString) {
      final Tag tag = new Tag();

      if(tagString.contains(categorySeparator)) {
        final List<String> split = tagString.split(categorySeparator);
        tag.id = Uri.decodeFull(split[0]);
        tag.category = Uri.decodeFull(split[1]);
      } else {
        tag.id = Uri.decodeFull(tagString);
      }
      return tag;
    });
    for(Tag t in tags) {
      this.add(new TagWrapper(t));
    }
  }

  @override
  Iterator<TagWrapper> get iterator => _list.iterator;

  void clear() => _list.clear();

  void add(TagWrapper tag) {
    if(indexOf(tag)!=-1)
      return;
    _list.add(tag);
  }
  void remove(TagWrapper tag) {
    final int i = indexOf(tag);
    if(i==-1)
      return;
    _list.removeAt(i);
  }

  int indexOf(TagWrapper tag) {
    for(int i = 0; i < _list.length; i++) {
      final TagWrapper t = _list[i];
      if(tag.equals(t)) {
        return i;
      }
    }
    return -1;
  }

  static const String categorySeparator = ":";
  static const String tagSeparator = ",";

  String toQueryString() {
    return _list.map((TagWrapper t) {
      final StringBuffer tagOutput = new StringBuffer();
      if(StringTools.isNotNullOrWhitespace(t.tag.category)) {
        tagOutput.write(Uri.encodeFull(t.tag.category));
        tagOutput.write(categorySeparator);
      }
      tagOutput.write(Uri.encodeFull(t.tag.id));
      return tagOutput.toString();
    }).join(tagSeparator);
  }

  List<Tag> toListOfTags() => new List<Tag>.from(_list.map((TagWrapper t) => t.tag));

}