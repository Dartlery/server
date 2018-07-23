import 'package:di/di.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:dartlery/data_sources/mongo/mongo.dart';
import 'package:dartlery/data_sources/postgres/postgres.dart';
import 'package:dartlery_shared/tools.dart';
import '../src/database_info.dart';
export 'interfaces/interfaces.dart';

final Logger _log = new Logger('Model');

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
    throw new Exception("Legacy does not support PostgreSQL, use Mongo");
  }
  return new ModuleInjector(<Module>[module]);
}
