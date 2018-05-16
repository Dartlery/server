import 'package:dartlery/data/data.dart';
import 'package:dartlery/api/api.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:dartlery/client.dart';
import 'dart:html' as html;

abstract class AView {
  String formatTag(Tag t) => TagWrapper.formatTag(t);
  String tagToQueryString(Tag t) => TagWrapper.createQueryStringForTag(t);

  String getFullFileUrl(Item item) {
    if (item == null || isNullOrWhitespace(item.id)) return "";
    if (item.fullFileAvailable)
      return getImageUrl(item.id, ItemFileType.full);
    else
      return getImageUrl(item.id, ItemFileType.original);
  }

  String getOriginalFileUrl(String value) {
    if (isNullOrWhitespace(value)) return "";
    final String output = getImageUrl(value, ItemFileType.original);
    return output;
  }

  String getThumbnailFileUrl(String value) {
    if (isNullOrWhitespace(value)) return "";
    final String output = getImageUrl(value, ItemFileType.thumbnail);
    return output;
  }

  void cancelEvent(html.Event e) {
    e.stopPropagation();
    e.preventDefault();
    e.stopImmediatePropagation();
  }
}
