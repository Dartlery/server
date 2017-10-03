import 'dart:async';

import 'package:dartlery_shared/global.dart';
import 'package:dartlery/client.dart';
import 'package:dartlery/api/api.dart';

import 'package:angular/core.dart';
import 'package:lib_angular/angular.dart';
import 'package:lib_angular/tools.dart';

export 'package:dartlery/api/api.dart' show PaginatedResponse;

@Injectable()
class ApiService extends GalleryApi {
  final SettingsService _settings;
  ApiService(this._settings)
      : super(new ApiHttpClient(_settings),
            rootUrl: getServerRoot(), servicePath: galleryApiPath);
}
