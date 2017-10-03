import 'package:di/di.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:dartlery/data_sources/mongo/mongo.dart';
import 'package:tools/tools.dart';
import 'package:server/data_sources/interfaces.dart';
import 'package:server/data_sources/mongo/mongo.dart';

export 'package:server/data_sources/interfaces.dart';
export 'interfaces/interfaces.dart';
import 'package:dartlery/data/data.dart';

final Logger _log = new Logger('Model');

ModuleInjector createDataSourceModuleInjector(String connectionString) {
  final Module module = new Module()
    ..bind(AItemDataSource, toImplementation: MongoItemDataSource)
    ..bind(AUserDataSource, toImplementation: MongoUserDataSource)
    ..bind(ATagDataSource, toImplementation: MongoTagDataSource)
    ..bind(ATagCategoryDataSource, toImplementation: MongoTagCategoryDataSource)
    ..bind(ABackgroundQueueDataSource,
        toImplementation: MongoBackgroundQueueDataSource)
    ..bind(AExtensionDataSource, toImplementation: MongoExtensionDataSource)
    ..bind(AImportResultsDataSource,
        toImplementation: MongoImportResultsDataSource)
    ..bind(AImportBatchDataSource, toImplementation: MongoImportBatchDataSource)
    ..bind(MongoTagDataSource)
    ..bind(ALogDataSource, toImplementation: MongoLogDataSource)
    ..bind(MongoDbConnectionPool,
        toFactory: () => new MongoDbConnectionPool(connectionString));

  return new ModuleInjector(<Module>[module]);
}
