import 'package:di/di.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:dartlery/data_sources/mongo/mongo.dart';
import 'package:dartlery_shared/tools.dart';
import 'package:orm/orm.dart';
import'src/tag_data_source.dart';


export 'interfaces/interfaces.dart';
export 'src/tag_data_source.dart';

final Logger _log = new Logger('Model');

ModuleInjector createDataSourceModuleInjector(String connectionString) {
  final Module module = new Module()
    ..bind(ADatabaseContext, toFactory: () => new MongoDatabaseContext(connectionString))
    ..bind(TagDataSource)

    ..bind(AItemDataSource, toImplementation: MongoItemDataSource)
    ..bind(AUserDataSource, toImplementation: MongoUserDataSource)
    ..bind(ATagDataSource, toImplementation: MongoTagDataSource)
    ..bind(ATagCategoryDataSource, toImplementation: MongoTagCategoryDataSource)
    ..bind(ABackgroundQueueDataSource,
        toImplementation: MongoBackgroundQueueDataSource)
    ..bind(AExtensionDataSource, toImplementation: MongoExtensionDataSource)
    ..bind(AImportResultsDataSource,
        toImplementation: MongoImportResultsDataSource)
    ..bind(AImportBatchDataSource,
        toImplementation: MongoImportBatchDataSource)
    ..bind(ALogDataSource, toImplementation:  MongoLogDataSource)
    ..bind(MongoDbConnectionPool,
        toFactory: () => new MongoDbConnectionPool(connectionString));

  return new ModuleInjector(<Module>[module]);
}
