part of model;

class FilesModel {
  final Logger _log = new Logger('FilesModel');
  
  final List<String> _allowedMimeTypes = new List<String>();
  
  mysql.ConnectionPool _pool;

 
  FilesModel(this._pool) {
    _allowedMimeTypes.add("image/jpeg");
    _allowedMimeTypes.add("image/gif");
    _allowedMimeTypes.add("image/png");
  }
  
  Future<int> updateFile(int id, {ContentType ct: null, List<String> tags}) { 
    this._log.info("Update requested for file ${id}");
    return new Future.sync(() {
      
    });
  }
  
  Future setTags(int id, List<String> tags) {
    this._log.info("Setting tags for file ${id}");
    return new Future.sync(() {
      if(tags==null||tags.length==0) {
        return;
      }
      
      
    });
  }
  
  Future<int> createFile(ContentType ct, List<int> data, List<String> tags) {
    this._log.info("Creating file");
    return new Future.sync(() {
      
      
      // Verify submitted mime type
      if(data.length >= mime.defaultMagicNumbersMaxLength) {
        String mime_str = mime.lookupMimeType("genericfilename",
            headerBytes: data.sublist(0,mime.defaultMagicNumbersMaxLength));
        
        if(mime_str==null) {
          this._log.warning("No mime type for uploaded data!");
          mime_str = ct.toString();
        } else {
          ContentType type = ContentType.parse(mime_str);
          this._log.warning("Uploaded data claims to be ${ct}, but validation says it's ${mime_str}");
        }
        
        if(!this._allowedMimeTypes.contains(mime_str)) {
            throw new FileTypeNotSupportedException("Provided file type is not allowed: ${mime_str}");        
        }
      }
      
      
      
      SHA256 sha = new SHA256();
      sha.add(data);
      List<int> hash = sha.close();
      String hash_string = CryptoUtils.bytesToHex(hash);

      this._log.info("File hash: " + hash_string);
      
      return this._pool.prepare("SELECT COUNT(*) AS count FROM files WHERE hash = ?").then((query) {
        return query.execute([hash]).then((results) {
          return results.forEach((row) {
            if(row.count>0) {
              throw new EntityExistsException(hash_string);
            }
          }); 
        });
      }).then((_) {
        // Write the file to the file system
        Directory file_dir = new Directory(path.join(Directory.current.path,SettingsModel.STATIC_DIR,SettingsModel.FILES_DIR));
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
        return this._pool.prepare("INSERT INTO files (hash,mime_type) VALUES (?,?)").then((query) {
          return query.execute([hash,ct.toString()]).then((results) {
            return results.insertId;
          });
        });
      }).then((id) {
        if(tags!=null&&tags.length>0) {
          return this.setTags(id, tags).then((_) {
            return id;
          });
        } else {
          return id;
        }
      });
    });
  }
  
  static const String STATIC_FILE_URL = "http://127.0.0.1:8888/static/files/";
  static const String STATIC_THUMBS_URL = "http://127.0.0.1:8888/static/thumbs/";
  
  static const String _GET_ALL_FILES_SQL = "SELECT files.id, HEX(hash) hash, tag FROM files LEFT JOIN tags ON files.id = tags.image ORDER by id DESC, tag";
  static const String _GET_ONE_FILE_SQL = "SELECT files.id, HEX(hash) hash, tag FROM files LEFT JOIN tags ON files.id = tags.image WHERE id= ? ORDER by id DESC, tag";
  
  Future getFiles([int id = -1]) {
    this._log.info("Getting all files");
    String sql;
    List args = new List();
    if(id==-1) {
      sql = _GET_ALL_FILES_SQL;
    } else {
      sql = _GET_ONE_FILE_SQL;
      args.add(id);
    }
    return new Future.sync(() {
      List<Map> output = new List<Map>();
      return this._pool.prepare(sql).then((query) {
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
              file["source"] = STATIC_FILE_URL + row.hash.toString().toLowerCase();
              file["thumbnail_source"] = STATIC_THUMBS_URL + row.hash.toString().toLowerCase();;
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
        });
      }).then((_) {
        return output;
      });
    });
  }  
}