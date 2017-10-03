import 'dart:io';

import 'package:dartlery/api/feeds/feed_api.dart';
import 'package:dartlery/api/gallery/gallery_api.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/services/background_service.dart';
import 'package:dartlery_shared/global.dart';
import 'package:di/di.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:server/api/api.dart';
import 'package:server/server.dart';
import 'package:tools/tools.dart';

export 'src/settings.dart';

const int fileHashPrefixLength = 2;


class DartleryServerContext extends AServerContext {
  DartleryServerContext(String rootDirectory, String dataPath):
        super(rootDirectory, dataPath),
        fullFilePath = path.join(Directory.current.path, hostedFilesFullPath),
        thumbnailFilePath =
        path.join(Directory.current.path, hostedFilesThumbnailsPath),
        originalFilePath =
        path.join(Directory.current.path, hostedFilesOriginalPath);

  String apiPrefix;

  final String fullFilePath;
  final String thumbnailFilePath;
  final String originalFilePath;

  String getFullFilePathForHash(String hash) =>
      path.join(fullFilePath, hash.substring(0, fileHashPrefixLength), hash);

  //serverRoot = Directory.current.path
  String getOriginalFilePathForHash(String hash) => path.join(
      originalFilePath, hash.substring(0, fileHashPrefixLength), hash);

  String getThumbnailFilePathForHash(String hash) => path.join(
      thumbnailFilePath, hash.substring(0, fileHashPrefixLength), hash);

//  Directory get fullFileDir => new Directory(fullFilePath);
//  Directory get originalDir => new Directory(originalFilePath);
//  Directory get thumbnailDir => new Directory(thumbnailFilePath);

}

DartleryServerContext get dartleryServerContext => serverContext;

class DartleryServer extends AApiServer {
  final Logger _log = new Logger('DartleryServer');
  final GalleryApi galleryApi;

  final FeedApi feedApi;

  DartleryServer(this.galleryApi, this.feedApi, AUserDataSource userDataSource,
      UserModel userModel)
      : super("dartlery", Directory.current.path, hostedFilesPath,
            userDataSource, userModel) {
    _log.fine("new Server($galleryApi, $feedApi, $userDataSource, $userModel)");
  }

  @override
  AServerContext createServerContext() =>
      new DartleryServerContext(this.rootDirectory, this.dataPath)
        ..apiPrefix = this.apiPrefix;


  @override
  List<AApi> getApis() => <AApi>[this.galleryApi, this.feedApi];


  static DartleryServer createInstance(String connectionString,
      {String instanceUuid}) {
    final ModuleInjector parentInjector =
        createModelModuleInjector(connectionString);

    final ModuleInjector injector = new ModuleInjector(<Module>[
      GalleryApi.injectorModules,
      FeedApi.injectorModules,
      new Module()..bind(DbLoggingHandler)..bind(DartleryServer)
    ], parentInjector);

    final DbLoggingHandler dbLoggingHandler = injector.get(DbLoggingHandler);
    Logger.root.onRecord.listen(dbLoggingHandler);

    final DartleryServer server = injector.get(DartleryServer);
    server.instanceUuid = instanceUuid ?? generateUuid();
    server.connectionString = connectionString;
    server.injector = injector;

    return server;
  }

  @override
  List<ABackgroundService> createBackgroundServices()  {
    final ModuleInjector injector =
    createModelModuleInjector(connectionString);

    final DbLoggingHandler dbLoggingHandler =
    new DbLoggingHandler(injector.get(ALogDataSource));
    Logger.root.onRecord.listen(dbLoggingHandler);


    final BackgroundService service = injector.get(BackgroundService);

    return <ABackgroundService>[service];
  }

}

enum SettingNames { itemNameFormat }
