import 'dart:isolate';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartlery/api/gallery/gallery_api.dart';
import 'package:dartlery/api/feeds/feed_api.dart';
import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/data_sources.dart';
import 'package:dartlery/model/model.dart';
import 'package:dartlery/extensions/extensions.dart';
import 'package:dartlery_shared/global.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:di/di.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:option/option.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' show join;
import 'package:rpc/rpc.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_auth/shelf_auth.dart';
import 'package:shelf_exception_handler/shelf_exception_handler.dart';
import 'package:shelf_route/shelf_route.dart';
import 'package:shelf_rpc/shelf_rpc.dart' as shelf_rpc;
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart' as path;

import 'src/exceptions/setup_required_exception.dart';
import 'src/db_logging_handler.dart';
import 'tools.dart';
import 'package:dartlery/services/background_service.dart';

export 'src/exceptions/setup_disabled_exception.dart';
export 'src/exceptions/setup_required_exception.dart';
export 'src/db_logging_handler.dart';
export 'src/settings.dart';


final String rootDirectory = Directory.current.path;
String serverRoot, serverApiRoot;

final String setupLockFilePath = path.join(rootDirectory, dataPath, "setup.lock");

bool _setupDisabled = false;

const String dataPath = "data";
//String getImagesRootUrl() {
//  return rpc.context.baseUrl + "/images/";
//}

Future<Null> checkIfSetupRequired() async {
  if (await isSetupAvailable()) throw new SetupRequiredException();
}

void disableSetup() {
  _setupDisabled = true;
}

final String fullFilePath = path.join(rootDirectory, hostedFilesFullPath);
final String thumbnailFilePath =
    path.join(rootDirectory, hostedFilesThumbnailsPath);
final String originalFilePath =
    path.join(rootDirectory, hostedFilesOriginalPath);

final Directory originalDir = new Directory(originalFilePath);
final Directory fullFileDir = new Directory(fullFilePath);
final Directory thumbnailDir = new Directory(thumbnailFilePath);

const int fileHashPrefixLength = 2;

String getFullFilePathForHash(String hash) =>
    path.join(fullFilePath, hash.substring(0, fileHashPrefixLength), hash);
String getOriginalFilePathForHash(String hash) =>
    path.join(originalFilePath, hash.substring(0, fileHashPrefixLength), hash);
String getThumbnailFilePathForHash(String hash) =>
    path.join(thumbnailFilePath, hash.substring(0, fileHashPrefixLength), hash);

Future<bool> isSetupAvailable() async {
  if (_setupDisabled) return false;

  if (await new File(setupLockFilePath).exists()) {
    _setupDisabled = true;
    return false;
  }
  return true;
}

Future<Map<String, dynamic>> loadJSONFile(String path) async {
  final File dir = new File(path);
  final String contents = await dir.readAsString();
  final Map<String, dynamic> output = JSON.decode(contents);
  return output;
}

class Server {
  final Logger _log = new Logger('Server');
  final GalleryApi galleryApi;
  final FeedApi feedApi;
  final AUserDataSource userDataSource;
  final UserModel userModel;

  String instanceUuid;
  String connectionString;
  String dataPath;
  ModuleInjector injector;

  final ApiServer _apiServer =
      new ApiServer(apiPrefix: apiPrefix, prettyPrint: true);

  HttpServer _server;

  Server(this.galleryApi, this.userDataSource, this.userModel, this.feedApi) {
    _log.fine("new Server($galleryApi, $userDataSource, $userModel)");
  }

  dynamic start(String bindIp, int port) async {
    try {
      _log.fine("Start start($bindIp, $port)");
      if (_server != null)
        throw new Exception("Server has already been started");

      final Handler staticImagesHandler = createStaticHandler(dataPath,
          listDirectories: false,
          serveFilesOutsidePath: false,
          useHeaderBytesForContentType: true,
          contentTypeResolver: mediaMimeResolver);
      // TODO: Submit patch to the static handler project to allow overriding the mime resolver


      _apiServer.addApi(this.galleryApi);
      _apiServer.addApi(this.feedApi);
      _apiServer.enableDiscoveryApi();

      _log.info("Data path: $dataPath");

      final JwtSessionHandler<Principal, SessionClaimSet> sessionHandler =
          new JwtSessionHandler<Principal, SessionClaimSet>(
              'dartlery', 'shhh secret', _getUser,
              idleTimeout: new Duration(hours: 1),
              totalSessionTimeout: new Duration(days: 7));

      final Middleware loginMiddleware =
          authenticate(<Authenticator<Principal>>[
        new UsernamePasswordAuthenticator<Principal>(_authenticateUser)
      ], sessionHandler: sessionHandler, allowHttp: true);

      final Middleware defaultAuthMiddleware = authenticate(
          <Authenticator<Principal>>[],
          sessionHandler: sessionHandler,
          allowHttp: true,
          allowAnonymousAccess: true);

      final Handler loginPipeline = const Pipeline()
          .addMiddleware(loginMiddleware)
          .addHandler((Request request) => new Response.ok(""));

      final Handler apiHandler = shelf_rpc.createRpcHandler(_apiServer);
      final Handler apiPipeline = const Pipeline()
          .addMiddleware(defaultAuthMiddleware)
          .addHandler(apiHandler);

      final Router<dynamic> root = router()
        ..add('/login/', <String>['POST', 'GET', 'OPTIONS'], loginPipeline)
        ..add("/data/", <String>['GET', 'OPTIONS'], staticImagesHandler,
            exactMatch: false)
        ..add(
            '/$apiPrefix/',
            <String>['GET', 'PUT', 'POST', 'HEAD', 'OPTIONS', 'DELETE'],
            apiPipeline,
            exactMatch: false)
        ..add('/discovery/', <String>['GET', 'HEAD', 'OPTIONS'], apiPipeline,
            exactMatch: false);

      String pathToBuild = join(rootDirectory, 'web/');
      final Directory siteDir = new Directory(pathToBuild);
      if (siteDir.existsSync()) {
        final Handler staticSiteHandler = createStaticHandler(pathToBuild,
            listDirectories: false,
            defaultDocument: 'index.html',
            serveFilesOutsidePath: true);
        root.add('/', <String>['GET', 'OPTIONS'], staticSiteHandler,
            exactMatch: false);
      }

      final Map<String, String> extraHeaders = <String, String>{
        'Access-Control-Allow-Headers':
            'Origin, X-Requested-With, Content-Type, Accept, Authorization',
        'Access-Control-Allow-Methods': 'POST, GET, PUT, HEAD, DELETE, OPTIONS',
        'Access-Control-Allow-Credentials': 'true',
        'Access-Control-Expose-Headers': 'Authorization',
        'Access-Control-Allow-Origin': '*'
      };
      Response _cors(Response response) =>
          response.change(headers: extraHeaders);
      final Middleware _fixCORS = createMiddleware(responseHandler: _cors);

      final Handler handler = const Pipeline()
          .addMiddleware(logRequests())
          .addMiddleware(exceptionHandler())
          .addMiddleware(_fixCORS)
          .addHandler(root.handler);

      _server = await io.serve(handler, bindIp, port);

      serverRoot = "http://${_server.address.host}:${_server.port}/";
      serverApiRoot = "$serverRoot$galleryApiPath";
      _log.info('Serving at $serverRoot');
    } catch (e, s) {
      _log.severe("Error while starting server", e, s);
    } finally {
      _log.fine("End start()");
    }
  }

  dynamic stop() async {
    if (_server == null) throw new Exception("Server has not been started");
    await _server.close();
    _server = null;
  }

  Future<Option<Principal>> _authenticateUser(
      String userName, String password) async {
    try {
      _log.fine("Start _authenticateUser($userName, password_obfuscated)");
      final Option<User> user =
          await userDataSource.getById(userName.trim().toLowerCase());

      if (user.isEmpty) return new None<Principal>();

      final Option<String> hashOption =
          await userDataSource.getPasswordHash(user.get().id);

      if (hashOption.isEmpty)
        throw new Exception("User does not have a password set");

      if (userModel.verifyPassword(hashOption.get(), password))
        return new Some<Principal>(new Principal(user.get().id));
      else
        return new None<Principal>();
    } catch (e, st) {
      _log.severe(e, st);
      rethrow;
    } finally {
      _log.fine("End _authenticateUser()");
    }
  }

  Future<Option<Principal>> _getUser(String uuid) async {
    final Option<User> user = await userDataSource.getById(uuid);
    if (user.isEmpty) return new None<Principal>();
    return new Some<Principal>(new Principal(user.get().id));
  }

  static Server createInstance(String connectionString, {String instanceUuid, String dataPath = null}) {
    final ModuleInjector parentInjector =
        createModelModuleInjector(connectionString);

    final ModuleInjector injector = new ModuleInjector(<Module>[
      GalleryApi.injectorModules,
      FeedApi.injectorModules,
      new Module()
        ..bind(DbLoggingHandler)
        ..bind(Server)
    ], parentInjector);

    final DbLoggingHandler dbLoggingHandler = injector.get(DbLoggingHandler);
    Logger.root.onRecord.listen(dbLoggingHandler);
    
    final Server server = injector.get(Server);
    server.instanceUuid = instanceUuid ?? generateUuid();
    server.connectionString = connectionString;
    server.injector = injector;

    if(dataPath==null) {
      server.dataPath = join(rootDirectory, hostedFilesPath);;
    } else {
      server.dataPath = dataPath;
    }


    return server;
  }
}

enum SettingNames { itemNameFormat }
