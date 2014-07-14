part of model;

class FilesModel {
  final Logger _log = new Logger('FilesModel');

  FilesModel() : super() {
  }

  static final String STATIC_FILE_URL = SettingsModel.API_URL + "static/files/";
  static final String STATIC_THUMBS_URL = SettingsModel.API_URL + "static/thumbs/";


  static const String _GET_TAGS_WRAPPER_SQL_START = 'SELECT f.id, f.name, f.source, HEX(hash) hash, tag FROM (';
  static const String _GET_TAGS_WRAPPER_SQL_END = ') f LEFT JOIN tags ON f.id = tags.image ';
  static const String _GET_TAGS_WRAPPER_ORDER_SQL = ' , tag ASC ';
  

  static const String _GET_FILES_ORDER_SQL = ' ORDER BY id ASC ';
  static const String _GET_FILES_LIMIT_SQL = ' LIMIT ?, ?';

  static const String _GET_FILES_INCLUDE_TAG_SQL = " EXISTS (SELECT 1 FROM tags WHERE image = id AND tag = ?) ";
  static const String _GET_FILES_EXCLUDE_TAG_SQL = " NOT EXISTS (SELECT 1 FROM tags WHERE image = id AND tag = ?) ";

  static const String VALID_SEARCH_ARG_REGEXP_STRING = r"^[-]?[a-zA-Z0-9_]+$";
  static final RegExp VALID_SEARCH_ARG_REGEXP = new RegExp(VALID_SEARCH_ARG_REGEXP_STRING);

  Future<int> updateFile(int id, mysql.Transaction tran, {List<String> tags: null, String name: null, String source: null}) {
    this._log.info("Update requested for file ${id}");

    return TagsModel.setTags(id, tags, tran);
  }




  Future<int> createFile(List<int> data, List<String> tags, mysql.Transaction tran, {String name: null, ContentType ct: null}) {
    this._log.info("Creating file");
    return new Future.sync(() {
      // Verify submitted mime type
      if (data.length >= mime.defaultMagicNumbersMaxLength) {
        String mime_str = mime.lookupMimeType("genericfilename", headerBytes: data.sublist(0, mime.defaultMagicNumbersMaxLength));

        if (mime_str == null) {
          this._log.warning("No mime type for uploaded data!");
          if (ct == null) {
            throw new Exception("Could not determine MIME type of file, and no content type was provided in submitted data");
          }
          mime_str = ct.toString();
        } else {
          ContentType type = ContentType.parse(mime_str);
          this._log.warning("Uploaded data claims to be ${ct}, but validation says it's ${mime_str}");
        }

        if (!SettingsModel.allowedMimeTypes.contains(mime_str)) {
          throw new FileTypeNotSupportedException("Provided file type is not allowed: ${mime_str}");
        }
      }



      SHA256 sha = new SHA256();
      sha.add(data);
      List<int> hash = sha.close();
      String hash_string = CryptoUtils.bytesToHex(hash);

      this._log.info("File hash: " + hash_string);

      return tran.prepare("SELECT COUNT(*) AS count FROM files WHERE hash = ?").then((query) {
        return query.execute([hash]).then((results) {
          return results.toList().then((result_list) {
            for(mysql.Row row in result_list) {
              if (row.count > 0) {
                throw new EntityExistsException(hash_string);
              }
            }
          });
        }).whenComplete(() {
          query.close();
        });
      }).then((_) {
        // Write the file to the file system
        Directory file_dir = new Directory(path.join(Directory.current.path, SettingsModel.STATIC_DIR, SettingsModel.FILES_DIR, hash_string.substring(0, 2)));
        if (!file_dir.existsSync()) {
          file_dir.createSync(recursive: true);
        }
        File file = new File(path.join(file_dir.path, hash_string));
        if (file.existsSync()) {
          file.deleteSync(recursive: false);
        }
        file.writeAsBytesSync(data, mode: FileMode.WRITE, flush: true);
      }).then((_) {
        // Create the thumbnail
        Thumbnailer.createThumbnailForBits(hash_string, data);
      }).then((_) {
        return tran.prepare("INSERT INTO files (hash,mime_type,name) VALUES (?,?,?)").then((query) {
          List args = new List();
          args.add(hash);
          args.add(ct.toString());
          if (name == null) {
            args.add("");
          } else {
            args.add(name);
          }
          return query.execute(args).then((results) {
            return results.insertId;
          }).then((insertId) {
            return insertId;
          }).whenComplete(() {
            query.close();
          });
        });
      }).then((id) {
        return TagsModel.setTags(id, tags, tran).then((_) {
          return id;
        });
      });
    });
  }

  Future getFiles(mysql.RetainedConnection con, {int id: -1, int limit: 60, int offset: 0, String search: null, List<String> order_by: null}) {
    List args = new List();
    Map output = new Map();
    List<Map> files = new List<Map>();
    output["files"] = files;
    
    QueryBuilder sql = new QueryBuilder("SELECT","files","f");
    sql.addField("*");

    return new Future.sync(() {
      if (id == -1) {
        if (search != null && search.trim() != "") {
          this._log.info("Searching for files matching ${search} (offset: ${offset} limit: ${limit})");
          List<String> search_args = search.split(" ");
          bool first = true;
          for (String search_arg in search_args) {
            if (!VALID_SEARCH_ARG_REGEXP.hasMatch(search_arg)) {
              throw new Exception("Invalid search arg: ${search_arg}");
            }

            if (search_arg.startsWith("-")) {
              sql.addCriteria(_GET_FILES_EXCLUDE_TAG_SQL,search_arg.substring(1));
            } else {
              sql.addCriteria(_GET_FILES_INCLUDE_TAG_SQL,(search_arg));
            }


            first = false;
          }
        } else {
          this._log.info("Getting all files (offset: ${offset} limit: ${limit})");
        }
        //builder.write(_GET_FILES_SQL_END);
      } else {
        this._log.info("Getting file ${id}");
        sql.addCriteria("id = ?",id);
      }

      return con.prepare(sql.getCountQuery()).then((query) {
        return query.execute(args).then((results) {
          return results.single.then((count) {
            output["count"] = count[0];
          });
        }).whenComplete(() {
          query.close();
        });
      });
    }).then((_) {
      if(order_by!=null&&order_by.length>0) {
        for(String order in order_by) {
          bool asc = true;
          if(order.startsWith("-")) {
            asc = false;
            order = order.substring(1);
          }
          switch(order) {
            case "id":
              sql.
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
