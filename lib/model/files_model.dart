part of model;

class FilesModel {
  final Logger _log = new Logger('FilesModel');
  
  FilesModel(): super() {
  }
  
  Future<int> updateFile(int id, mysql.Transaction tran, {List<String> tags: null, String name: null}) { 
    this._log.info("Update requested for file ${id}");
    
    
    return this.setTags(id, tags, tran); 
  }
  
  static const String _DELETE_TAGS_SQL = "DELETE FROM tags WHERE image = ?";
  static const String _SET_TAGS_SQL = "INSERT INTO tags (image,tag) VALUES (?,?)";
  
  Future setTags(int id, List<String> tags, mysql.Transaction transaction) {
    this._log.info("Setting tags for file ${id}");
    return new Future.sync(() {
      if(tags==null||tags.length==0) {
        return null;
      }
      return transaction.prepare(_DELETE_TAGS_SQL);
    }).then((mysql.Query query) {
      if(query==null) {
        return null;
      }
      return query.execute([id]).then((_) {
        return transaction.prepare(_SET_TAGS_SQL);
      }).then((mysql.Query  t_query) {
        List args = new List();
        for(String tag in tags) {
          if(tag!=null&&tag!="") {
            args.add([id,tag]);
          }
        }
        return t_query.executeMulti(args).then((_) {
          t_query.close();
        });
      }).then((_) {
        query.close();
      });
    });
  }
  
  Future<int> stageFile(List<int> data, List<String> tags, mysql.Transaction tran, {String name: null, ContentType ct: null}) {
    this._log.info("Creating file");
    return new Future.sync(() {
      // Verify submitted mime type
      if(data.length >= mime.defaultMagicNumbersMaxLength) {
        String mime_str = mime.lookupMimeType("genericfilename",
            headerBytes: data.sublist(0,mime.defaultMagicNumbersMaxLength));
        
        if(mime_str==null) {
          this._log.warning("No mime type for uploaded data!");
          if(ct==null) {
            throw new Exception("Could not determine MIME type of file, and no content type was provided in submitted data");
          }
          mime_str = ct.toString();
        } else {
          ContentType type = ContentType.parse(mime_str);
          this._log.warning("Uploaded data claims to be ${ct}, but validation says it's ${mime_str}");
        }
        
        if(!SettingsModel.allowedMimeTypes.contains(mime_str)) {
            throw new FileTypeNotSupportedException("Provided file type is not allowed: ${mime_str}");        
        }
      }
      
      
      
      SHA256 sha = new SHA256();
      sha.add(data);
      List<int> hash = sha.close();
      String hash_string = CryptoUtils.bytesToHex(hash);

      if(hash_string=="e81091c76538f4c202df25a31d4b7d646567b0a9d6be0c35595d6457c50e393d") {
        this._log.finest("Trouble image found");
      }
      
      this._log.info("File hash: " + hash_string);
      
      return tran.prepare("SELECT COUNT(*) AS count FROM files WHERE hash = ?").then((query) {
        return query.execute([hash]).then((results) {
          return results.forEach((row) {
            if(row.count>0) {
              throw new EntityExistsException(hash_string);
            }
          }); 
        }).then((_) {
          query.close();
        });
      }).then((_) {
        // Write the file to the file system
        Directory file_dir = new Directory(path.join(Directory.current.path,SettingsModel.STATIC_DIR,SettingsModel.FILES_DIR, hash_string.substring(0,2)));
        if(!file_dir.existsSync()) {
          file_dir.createSync(recursive: true);
        }
        File file = new File(path.join(file_dir.path,hash_string));
        if(file.existsSync()) {
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
          if(name==null) {
            args.add("");
          } else {
            args.add(name);
          }
          return query.execute(args).then((results) {
            return results.insertId;
          }).then((insertId) {
            query.close();
            return insertId;
          });
        });
      }).then((id) {
        return this.setTags(id, tags, tran).then((_) {
          return id;
        });
      });
    });
  }
  
  static String STATIC_FILE_URL = SettingsModel.API_URL + "static/files/";
  static String STATIC_THUMBS_URL = SettingsModel.API_URL + "static/thumbs/";
  
  static const String _GET_ALL_FILES_SQL = '''SELECT f.id, name, HEX(hash) hash, tag 
FROM (SELECT * FROM files ORDER BY id LIMIT 0, ?) f 
LEFT JOIN tags ON f.id = tags.image ORDER by id DESC, tag ASC''';
  
  static const String _GET_ONE_FILE_SQL = "SELECT files.id, name, HEX(hash) hash, tag FROM files LEFT JOIN tags ON files.id = tags.image WHERE id= ? ORDER by id DESC, tag ASC";
  
  Future getFiles(mysql.ConnectionPool pool, {int id: -1, int limit: 30}) {
    String sql;
    List args = new List();
    if(id==-1) {
      this._log.info("Getting all files (limited to ${limit})");
      sql = _GET_ALL_FILES_SQL;
      args.add(limit);
    } else {
      this._log.info("Getting file ${id}");
      args.add(id);
      sql = _GET_ONE_FILE_SQL;
    }
    return new Future.sync(() {
      List<Map> output = new List<Map>();
      return pool.prepare(sql).then((query) {
        return query.execute(args).then((results) {
          int last_id = -1;
          Map<String,Object> file = null;
          List<String> tags = null;
          return results.forEach((row) {
            if(last_id==-1||row.id!=last_id) {
              if(file!=null) {
                file["tags"] = tags;
                output.add(file);   
              }
              tags = new List<String>();
              file = new Map<String,Object>();
              file["id"] = row.id;
              if(row.name!=null&&row.name.toString()!="") {
                file["name"] = row.name.toString();
              }

              file["source"] = STATIC_FILE_URL + row.hash.toString().toLowerCase();
              file["thumbnail_source"] = STATIC_THUMBS_URL + row.hash.toString().toLowerCase();;
              file["link"] = SettingsModel.API_URL +"files/" + row.id.toString();
                  
              last_id = row.id;
            }
            if(row.tag!=null) {
              tags.add(row.tag);
            }
          }).then((_) {
            if(file!=null) {
              file["tags"] = tags;
              output.add(file);   
            }
          }); 
        }).then((_) {
          query.close();
        });
      }).then((_) {
        return output;
      });
    });
  }  
}