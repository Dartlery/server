import 'dart:async';
import 'package:logging/logging.dart';
import 'package:dartlery/data/data.dart';
import 'a_two_id_based_data_source.dart';

abstract class ATagDataSource extends ATwoIdBasedDataSource<Tag> {
  static final Logger _log = new Logger('ATagDataSource');



  Future<List<RedirectingTag>> getRedirects();
  Future<List<RedirectingTag>> getByRedirect(String id, String category);
  Future<Null> deleteByRedirect(String id, String category);

  @override
  Future<IdDataList<Tag>> search(String query, {int limit});

}
