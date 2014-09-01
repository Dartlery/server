part of model;

class ShimmieImportModel extends AImportModel {
  static final Logger _log = new Logger('ShimmieImportModel');
  
  static const String _SHIMMIE_FILE_LIST = "SELECT i.*, t.tag FROM images i LEFT JOIN image_tags it ON i.id = it.image_id LEFT JOIN tags t ON t.id = it.tag_id ORDER BY i.id ASC, t.tag ASC";
  
  Future beginImport(mysql.Transaction tran, String host, String db, String user, String password, String image_folder, {int port: 3306}) {
    List imported_files = new List();
    
    return new Future(() {
      mysql.ConnectionPool shimmie_pool  = 
        new mysql.ConnectionPool(host: host, port: port,
            user: user, password: password, db: db, max: 5);

      return shimmie_pool.query(_SHIMMIE_FILE_LIST).then((mysql.Results results) {
        return results.toList().then((result_list) {
          int last_id = -1;
          String name;
          String hash;
          int parent = -1;
          File source_file;
          List<String> tags;
          int current_id;
          int i = 0;
          return Future.forEach(result_list,  (row) {
            i++;
          //return results.forEach((mysql.Row row) {
            current_id = row.id;
            return new Future(() {
              if(last_id==-1||last_id!=current_id) {
                _log.info("Progress: ${i}/${result_list.length}");
                return new Future(() {
                  if(last_id!=-1) {
                    _log.info("Writing imported file: ${hash}");
                    return this._filesModel.createFile(source_file.readAsBytesSync(), tags, tran, name: name).then((o) {
                      _log.info("Writing as : ${0}");
                      imported_files.add(o);
                    });
                  }
                }).then((_) {
                  name = row.filename;
                  hash = row.hash;
                  if(row.parent_id!=null) {
                    parent = row.parent_id;
                  } else {
                    parent = -1;
                  }
                  tags = new List<String>();
                  
                  source_file = new File(path.join(image_folder,hash.substring(0,2),hash));
                  _log.info("File data source: ${source_file}");
                  if(!source_file.existsSync()) {
                    throw new Exception("The file for this shimmie image could not be found: ${hash}");
                  }
                });
              }
            }).then((_) {
              _log.info("Image tag: ${row.tag}");
              tags.add(row.tag);
              last_id = row.id;
            });
          }).then((_) {
            if(last_id!=-1) {
              _log.info("Writing imported file: ${hash}");
              return this._filesModel.createFile(source_file.readAsBytesSync(), tags, tran, name: name).then((id) {
                _log.info("Writing as : ${0}");
                imported_files.add(id);
              });
            } else {
              throw new Exception("No files found to import");
            }
          }).then((_) {
            return imported_files;
          });
        });
      });
    });
  }
  
}