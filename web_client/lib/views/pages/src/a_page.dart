import 'package:dartlery/client.dart';
import 'package:dartlery/services/services.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:angular2/router.dart';
import '../../src/a_api_error_thing.dart';

abstract class APage extends AApiErrorThing {



  APage(AuthenticationService auth, Router router): super(router, auth);

  String getOriginalFileUrl(String value) {
    if(StringTools.isNullOrWhitespace(value))
      return "";
    final String output = getImageUrl(value, ImageType.original);
    return output;
  }

  String getThumbnailFileUrl(String value) {
    final String output = getImageUrl(value, ImageType.thumbnail);
    return output;
  }



}
