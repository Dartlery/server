import 'dart:html' as html;
import 'package:dartlery/client.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:angular2/router.dart';
import '../../src/a_api_error_thing.dart';
import 'package:dartlery/api/api.dart';

abstract class APage extends AApiErrorThing {



  APage(AuthenticationService auth, Router router): super(router, auth);

  void cancelEvent(html.Event e) {
    e.stopPropagation();
    e.preventDefault();
    e.stopImmediatePropagation();
  }

  String getFullFileUrl(Item item) {
    if(item==null||StringTools.isNullOrWhitespace(item.id))
      return "";
    if(item.fullFileAvailable)
      return getImageUrl(item.id, ItemFileType.full);
    else
      return getImageUrl(item.id, ItemFileType.original);
  }

  String getOriginalFileUrl(String value) {
    if(StringTools.isNullOrWhitespace(value))
      return "";
    final String output = getImageUrl(value, ItemFileType.original);
    return output;
  }

  String getThumbnailFileUrl(String value) {
    if(StringTools.isNullOrWhitespace(value))
      return "";
    final String output = getImageUrl(value, ItemFileType.thumbnail);
    return output;
  }



}
