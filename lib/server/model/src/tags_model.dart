part of model;

class TagsModel {
  static final Logger _log = new Logger('TagsModel');

  static const String _VALID_TAG_REGEXP_STRING = r"^[^-].*$";
  static final RegExp _VALID_TAG_REGEXP = new RegExp(_VALID_TAG_REGEXP_STRING);

  static const String _DELETE_TAGS_SQL = "DELETE FROM tags WHERE image = ?";
  static const String _SET_TAGS_SQL = "INSERT INTO tags (image,tag) VALUES (?,?)";

  static bool isValidTag(String tag) {
    return _VALID_TAG_REGEXP.hasMatch(tag);
  }
  
  static Future<List> getTags(mysql.RetainedConnection con, {int limit: 50, List<String> order_by: null, List<String> expand: null}) {
    Map output = new Map();
    List tags = new List();
    return new Future(() {
      QueryBuilder sql = new QueryBuilder(QueryBuilder.SELECT,"tags","t");
      sql.addField("t.tag");
      
      bool expand_count = false;

      if(expand.length>0) {
        for(String name in expand) {
          switch(name) {
            case "count":
              expand_count = true;
              sql.addField("COUNT(*) AS count");
              break;
            default:
              throw new ValidationException("Cannot expand ${name}");
          }
        }
      }
      
      if(order_by.length>0) {
        for(String order in order_by) {
          bool asc = true;
          if(order.startsWith("-")) {
            asc=false;
            order = order.substring(1);
          }
          String new_order;
          switch(order) {
            case "count":
              new_order = "COUNT(*)";
              break;
            case "tag":
              new_order = "t.tag";
              break;
            default:
              throw new ValidationException("Cannot order by ${order}");
          }
          sql.addOrder(new_order,asc);
        }
      }
      
      sql.addOrder("t.tag");
      sql.addGroupBy("t.tag");
      sql.setLimit(0, limit);
      
      return con.prepareExecute(sql.toString(),[]).then((results) {
        return results.forEach((row) {
          Map tag = new Map();
          tag["tag"] = row.tag;
          if(expand_count) {
            tag["count"] = row.count;
          }
          tags.add(tag);
        });
      }).then((_) {
        output["tags"] = tags;
        
        return con.prepare(sql.getCountQuery()).then((query) {
          return query.execute().then((results) {
            return results.single.then((count) {
              output["count"] = count[0];
            });
          }).whenComplete(() {
            query.close();
          });
        });

      });
    }).then((_) {
      return output;
    });
  }
  
  
  static Future setTags(int id, List<String> tags, mysql.Transaction transaction) {
    _log.info("Setting tags for file ${id}");
    List args = new List();
    return new Future(() {
      if (tags == null || tags.length == 0) {
        return null;
      }
      for (String tag in tags) {
        if (tag != null && tag != "") {
          if (!isValidTag(tag)) {
            throw new Exception("Invalid tag: ${tag}");
          }
          args.add([id, tag]);
        }
      }


      return transaction.prepare(_DELETE_TAGS_SQL);
    }).then((mysql.Query query) {
      if (query == null) {
        return null;
      }
      return query.execute([id]).then((_) {
        return transaction.prepare(_SET_TAGS_SQL);
      }).then((mysql.Query t_query) {
        return Future.forEach(args, (arg) {
          return t_query.execute(arg);
        }).whenComplete(() {
          t_query.close();
        });
      }).whenComplete(() {
        query.close();
      });
    });
  }
  

}