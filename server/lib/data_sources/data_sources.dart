import 'package:dice/dice.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:dartlery/data_sources/mongo/mongo.dart';
import 'package:dartlery/data_sources/postgres/postgres.dart';
import 'package:dartlery_shared/tools.dart';
import '../src/database_info.dart';
export 'interfaces/interfaces.dart';

final Logger _log = new Logger('Model');

<<<<<<< HEAD
class DataSourceModule extends Module {
  final String _connectionString;

  DataSourceModule(this._connectionString);

  @override
  void configure() {
    register(AItemDataSource).toType(MongoItemDataSource).asSingleton();

    register(AUserDataSource).toType(MongoUserDataSource).asSingleton();
    register(ATagDataSource).toType(MongoTagDataSource).asSingleton();
    register(ATagCategoryDataSource).toType(MongoTagCategoryDataSource).asSingleton();
    register(ABackgroundQueueDataSource).toType(MongoBackgroundQueueDataSource).asSingleton();
    register(AExtensionDataSource).toType(MongoExtensionDataSource).asSingleton();
    register(AImportResultsDataSource).toType(MongoImportResultsDataSource).asSingleton();
    register(AImportBatchDataSource).toType(MongoImportBatchDataSource).asSingleton();
    register(AItemDataSource).toType(MongoItemDataSource).asSingleton();
    register(MongoTagDataSource).asSingleton();
    register(ALogDataSource).toType(MongoLogDataSource).asSingleton();
    register(MongoDbConnectionPool).toInstance(new MongoDbConnectionPool(_connectionString));
  }
=======
ModuleInjector createDataSourceModuleInjector(DatabaseInfo dbInfo) {
  final Module module = new Module();
  if (dbInfo is MongoDatabaseInfo) {
    module
      ..bind(AItemDataSource, toImplementation: MongoItemDataSource)
      ..bind(AUserDataSource, toImplementation: MongoUserDataSource)
      ..bind(ATagDataSource, toImplementation: MongoTagDataSource)
      ..bind(ATagCategoryDataSource,
          toImplementation: MongoTagCategoryDataSource)
      ..bind(ABackgroundQueueDataSource,
          toImplementation: MongoBackgroundQueueDataSource)
      ..bind(AExtensionDataSource, toImplementation: MongoExtensionDataSource)
      ..bind(AImportResultsDataSource,
          toImplementation: MongoImportResultsDataSource)
      ..bind(AImportBatchDataSource,
          toImplementation: MongoImportBatchDataSource)
      ..bind(MongoTagDataSource)
      ..bind(ALogDataSource, toImplementation: MongoLogDataSource)
      ..bind(MongoDbConnectionPool,
          toFactory: () => new MongoDbConnectionPool(dbInfo.connectionString));
  } else {
    module
//      ..bind(AItemDataSource, toImplementation: MongoItemDataSource)
//      ..bind(AUserDataSource, toImplementation: MongoUserDataSource)
//      ..bind(ATagDataSource, toImplementation: MongoTagDataSource)
//      ..bind(ATagCategoryDataSource,
//          toImplementation: MongoTagCategoryDataSource)
//      ..bind(ABackgroundQueueDataSource,
//          toImplementation: MongoBackgroundQueueDataSource)
//      ..bind(AExtensionDataSource, toImplementation: MongoExtensionDataSource)
//      ..bind(AImportResultsDataSource,
//          toImplementation: MongoImportResultsDataSource)
//      ..bind(AImportBatchDataSource,
//          toImplementation: MongoImportBatchDataSource)
//      ..bind(MongoTagDataSource)
//      ..bind(ALogDataSource, toImplementation: MongoLogDataSource)
      ..bind(MongoDbConnectionPool,
          toFactory: () => new PostgresConnectionPool(dbInfo));


  }
  return new ModuleInjector(<Module>[module]);
>>>>>>> master
}

