import 'dart:async';
import 'package:dartlery/data/data.dart';
import 'package:orm/orm.dart';

class TagDataSource {
  ADatabaseContext _context;

  TagDataSource(this._context);

  Future<TagInfo> getByIdAndCategory(String id, String category) =>
      _context.getOneByQuery(TagInfo, where.equals("id", id).equals("category", category));

  Future<TagInfo> getByInternalId(dynamic id) => _context.getByInternalID(TagInfo, id);
}