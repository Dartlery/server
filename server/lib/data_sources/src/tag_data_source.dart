import 'dart:async';

import 'package:dartlery/data/data.dart';
import 'package:orm/orm.dart';

class TagDataSource {
  DatabaseContext _context;

  TagDataSource(this._context);

  Future<bool> existsByIdAndCategory(String id, String category) =>
      _context.existsByCriteria(
          TagInfo, where.equals("id", id).equals("category", category));

  Future<Null> deleteByIdAndCategory(String id, String category) =>
      _context.deleteByCriteria(
          TagInfo, where.equals("id", id).equals("category", category));


  Future<TagInfo> getByIdAndCategory(String id, String category) =>
      _context.getOneByCriteria(
          TagInfo, where.equals("id", id).equals("category", category));

  Future<TagInfo> getByInternalId(dynamic id) =>
      _context.getByInternalID(TagInfo, id);

  Future<Null> update(TagInfo tag) =>
      _context.update(tag);


  Future<dynamic> add(TagInfo tag) =>
      _context.add(tag);
}
