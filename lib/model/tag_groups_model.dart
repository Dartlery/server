part of model;

class TagGroupsModel {
  final Logger _log = new Logger('TagGroupsModel');

  TagGroupsModel() : super() {
  }

  static const String GET_TAG_GROUPS_SQL = "SELECT DISTINCT tag_group FROM tag_groups ORDER BY tag_group";
  static const String GET_TAG_GROUP_SQL = "SELECT tag_group, tag FROM tag_groups ORDER BY tag WHERE tag_group = ?";
  
  Future<List> getGroups(mysql.RetainedConnection con) {
    List<String> output = new List<String>();
    return new Future.sync(() {
      return con.prepareExecute(GET_TAG_GROUPS_SQL, []).then((mysql.Results results) {
        return results.forEach((row) {
          output.add(row.tag_group);
        }).then((_) {
          return output;
        });
      });
    });
  }
  

  
  Future setTagGroup(String group, List<String> tags, mysql.Transaction transaction) {
    this._log.info("Setting tags for group ${group}");
    List args = new List();
    return new Future.sync(() {
      if (tags == null || tags.length == 0) {
        return null;
      }
      for (String tag in tags) {
        if (tag != null && tag != "") {
          if (!TagsModel.isValidTag(tag)) {
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


  Future getFiles(mysql.RetainedConnection con, {int id: -1, int limit: 60, int offset: 0, String search: null, List<String> order_by: null}) {
    String sql;
    List args = new List();
    Map output = new Map();
    List<Map> files = new List<Map>();
    output["files"] = files;
    StringBuffer builder = new StringBuffer();
    return new Future.sync(() {
      if (id == -1) {
        builder.write(_GET_FILES_SQL);
        if (search != null && search.trim() != "") {
          this._log.info("Searching for files matching ${search} (offset: ${offset} limit: ${limit})");
          List<String> search_args = search.split(" ");
          builder.write(" WHERE ");
          bool first = true;
          for (String search_arg in search_args) {
            if (!VALID_SEARCH_ARG_REGEXP.hasMatch(search_arg)) {
              throw new Exception("Invalid search arg: ${search_arg}");
            }

            if (!first) {
              builder.write(" AND ");
            }
            if (search_arg.startsWith("-")) {
              builder.write(_GET_FILES_EXCLUDE_TAG_SQL);
              args.add(search_arg.substring(1));
            } else {
              builder.write(_GET_FILES_INCLUDE_TAG_SQL);
              args.add(search_arg);
            }


            first = false;
          }
        } else {
          this._log.info("Getting all files (offset: ${offset} limit: ${limit})");
        }
        //builder.write(_GET_FILES_SQL_END);
      } else {
        this._log.info("Getting file ${id}");
        builder.write(_GET_SINGLE_FILE_SQL);
        args.add(id);
      }
      sql = builder.toString();

      return con.prepare(_GET_COUNT_WRAPPER_START + sql + _GET_COUNT_WRAPPER_END).then((query) {
        return query.execute(args).then((results) {
          return results.single.then((count) {
            output["count"] = count[0];
          });
        }).whenComplete(() {
          query.close();
        });
      });
    }).then((_) {
      StringBuffer order_string = new StringBuffer();
      if(order_by!=null&&order_by.length>0) {
        order_string.write(" ORDER BY ");
        bool first = true;
        for(String order in order_by) {
          if(!first) {
            order_string.write(",");
          } else {
            first = false;
          }
          bool asc = true;
          if(order.startsWith("-")) {
            asc = false;
            order = order.substring(1);
          }
          switch(order) {
            case "id":
              order_string.write(" id ");
              break;
            default:
              throw new ValidationException("Sorting by \"${order}\" not supported");
          }
          if(asc) {
            order_string.write(" ASC ");
          } else {
            order_string.write(" DESC ");
          }
        }
      } else {
        order_string.write(_GET_FILES_ORDER_SQL);
      }
      
      builder.write(order_string.toString());

      if (id == -1) {
        builder.write(_GET_FILES_LIMIT_SQL);
        args.add(offset);
        args.add(limit);
      }

      builder.write(_GET_TAGS_WRAPPER_SQL_END);
      
      sql = _GET_TAGS_WRAPPER_SQL_START  + builder.toString() + order_string.toString() + _GET_TAGS_WRAPPER_ORDER_SQL;
      
      return con.prepare(sql).then((query) {
        return query.execute(args).then((results) {
          int last_id = -1;
          Map<String, Object> file = null;
          List<String> tags = null;
          return results.forEach((row) {
            if (last_id == -1 || row.id != last_id) {
              if (file != null) {
                file["tags"] = tags;
                files.add(file);
              }
              tags = new List<String>();
              file = new Map<String, Object>();
              file["id"] = row.id;
              if (row.name != null && row.name.toString() != "") {
                file["name"] = row.name.toString();
              }
              if (row.name != null && row.source.toString() != "") {
                file["source"] = row.source.toString();
              }

              file["file"] = STATIC_FILE_URL + row.hash.toString().toLowerCase();
              file["thumbnail"] = STATIC_THUMBS_URL + row.hash.toString().toLowerCase();
              ;
              file["link"] = SettingsModel.API_URL + "files/" + row.id.toString();

              last_id = row.id;
            }
            if (row.tag != null) {
              tags.add(row.tag);
            }
          }).then((_) {
            if (file != null) {
              file["tags"] = tags;
              files.add(file);
            }
          });
        }).whenComplete(() {
          query.close();
        });
      }).then((_) {
        return output;
      });
    });
  }
}
