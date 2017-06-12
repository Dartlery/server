import 'dart:convert';
import 'package:dartlery/data/data.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery/api/api.dart';
import 'dart:html';
import 'package:dartlery_shared/global.dart';

class TagList extends Iterable<TagWrapper> {
  final List<TagWrapper> _list = <TagWrapper>[];

  TagList();

  TagList.from(Iterable<TagWrapper> input) {
    for (TagWrapper t in input) {
      this.add(t);
    }
  }

  void addTags(List<Tag> tags) {
    for (Tag t in tags) {
      this.add(new TagWrapper.fromTag(t));
    }
  }

  void addTagInfos(List<TagInfo> tags) {
    for (TagInfo t in tags) {
      this.add(new TagWrapper.fromTagInfo(t));
    }
  }

  void addTagList(TagList tags) {
    for (TagWrapper t in tags) {
      this.add(t);
    }
  }

  TagList.fromQueryString(String query) {
    final Iterable<Tag> tags =
        query.split(tagDeliminator).map((String tagString) {
      final Tag tag = new Tag();

      if (tagString.contains(categoryDeliminator)) {
        final List<String> split = tagString.split(categoryDeliminator);
        tag.category = Uri.decodeFull(split[0]);
        tag.id = Uri.decodeFull(split[1]);
      } else {
        tag.id = Uri.decodeFull(tagString);
      }
      return tag;
    });
    for (Tag t in tags) {
      this.add(new TagWrapper.fromTag(t));
    }
  }

  String toJson() {
    final List<Map<String,String>> output = new List<Map<String,String>>();

    for(TagWrapper tag in this) {
      final Map<String,String> tagMap = <String,String>{};
      tagMap["id"] = tag.id;
      if(tag.hasCategory) {
        tagMap["category"] = tag.category;
      }
      output.add(tagMap);
    }

    final String outputJson = new JsonEncoder().convert(output);
    return  outputJson;
  }

  @override
  Iterator<TagWrapper> get iterator => _list.iterator;

  void clear() => _list.clear();

  void add(TagWrapper tag) {
    if (indexOf(tag) != -1) return;
    _list.add(tag);
  }

  void remove(TagWrapper tag) {
    final int i = indexOf(tag);
    if (i == -1) return;
    _list.removeAt(i);
  }

  int indexOf(TagWrapper tag) {
    for (int i = 0; i < _list.length; i++) {
      final TagWrapper t = _list[i];
      if (tag.equals(t)) {
        return i;
      }
    }
    return -1;
  }

  static String convertToQueryString(List<Tag> tags) {
    return tags.map((Tag t) {
      return TagWrapper.createQueryStringForTag(t);
    }).join(tagDeliminator);
  }

  String toQueryString() => convertToQueryString(this.toListOfTags());

  List<Tag> toListOfTags() =>
      new List<Tag>.from(_list.map((TagWrapper t) => t.tag));

  bool compare(TagList otherList) {
    for (TagWrapper tag in otherList) {
      if (indexOf(tag) == -1) return false;
    }
    if (length != otherList.length) return false;

    return true;
  }
}
