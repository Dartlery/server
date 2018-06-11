import 'package:dartlery/data/data.dart';
import 'package:dartlery/data_sources/interfaces/interfaces.dart';
import 'package:logging/logging.dart';

import 'package:dice/dice.dart';
@Injectable()
class DbLoggingHandler {
  final ALogDataSource _logDataSource;

  @inject
  DbLoggingHandler(this._logDataSource);

  void call(LogRecord logRecord) {
    try {
      this._logDataSource.create(new LogEntry.fromLogRecord(logRecord));
    } catch (e, st) {
      // Where would I log it?
    }
  }
}


class LoggingModule extends Module {

  @override
  void configure() {
    register(DbLoggingHandler).asSingleton();
  }
}