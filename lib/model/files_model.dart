part of model;

class FilesModel {
  final Logger _log = new Logger('FilesModel');
  
  mysql.ConnectionPool _pool;

 
  FilesModel(this._pool) {
    
  }
  
  
  static String FILES_DIR = 'files'; 
  static String THUMBS_DIR = 'thumbs'; 
  
  Future<int> CreateFile(ContentType ct, List<int> data, String tags) {
    this._log.info("Creating file");
    return new Future.sync(() {
      // Verify submitted mime type
      if(data.length >= mime.defaultMagicNumbersMaxLength) {
        String mime_str = mime.lookupMimeType("genereicfilename",
            headerBytes: data.sublist(0,mime.defaultMagicNumbersMaxLength));
        if(mime_str==null) {
          this._log.warning("No mime type for uploaded data!");
        } else { 
          ContentType type = ContentType.parse(mime_str);
          this._log.warning("Uploaded data claims to be ${ct}, but validation says it's ${mime_str}");
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
        Directory file_dir = new Directory(path.join(Directory.current.path,FILES_DIR));
        if(!file_dir.existsSync()) {
          file_dir.createSync(recursive: true);
        }
        File file = new File(path.join(file_dir.path,hash_string));
        if(file.existsSync()) {
          file.deleteSync(recursive: false);
        }
        file.writeAsBytesSync(data, mode: FileMode.WRITE, flush: true);
      }).then((_) { 
        return this._pool.prepare("INSERT INTO files (hash,mime_type) VALUES (?,?)").then((query) {
          return query.execute([hash,ct.toString()]).then((results) {
            return results.insertId;
          });
        });
      });
    });
  }
  
  
  Future GetAllFiles() {
    this._log.info("Getting all files");
    
    return new Future.sync(() {
      List<Map> output = new List<Map>();      
    
      for(int i = 0; i < 5; i++) {
        Map<String,Object> file = new Map<String,Object>();
        file["id"] = i;
        file["source"] = "http://www.gravatar.com/avatar/bb56104632b355716a430ddef589fd15.png";
        file["thumbnail_source"] = "http://www.gravatar.com/avatar/bb56104632b355716a430ddef589fd15.png";
        List<String> tags = new List<String>();
        tags.add("tag1");
        tags.add("tag2");
        tags.add("tag3");
        tags.add("tag4");
        
        file["tags"] = tags;
        
        output.add(file);      
      }
      
      return output;
    });
  }  
}