import 'dart:async';

import 'package:dartlery_shared/global.dart';
import 'package:dartlery/client.dart';
import 'package:dartlery/api/api.dart';

import 'package:angular/core.dart';
import 'settings_service.dart';

export 'package:dartlery/api/api.dart';

@Injectable()
class ApiService extends GalleryApi {
  final SettingsService _settings;
  ApiService(this._settings)
      : super(new ApiHttpClient(_settings),
            rootUrl: getServerRoot(), servicePath: galleryApiPath);
}
