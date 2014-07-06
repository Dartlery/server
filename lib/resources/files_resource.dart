part of resources;


class FilesResource extends RestResource {
  final Logger _log = new Logger('FilesResource');
  
  static const String _RESOURCE_PATH_REGEX = r'^/files/([^/]*)/?$';

  //ADatabase _db;
  mysql.ConnectionPool _pool;
  
  FilesModel _model;

  FilesResource(this._pool): super(_RESOURCE_PATH_REGEX) {
    this._model = new FilesModel(this._pool);
    setMethodHandler(HttpMethod.GET, _getMethod);
    setMethodHandler(HttpMethod.POST, _postMethod);
    setMethodHandler(HttpMethod.PUT, _putMethod);
    this.addAcceptableContentType(ContentType.JSON,HttpMethod.POST);
  }
  
  
  Future _putMethod(RestRequest request) {
    return this._pool.startTransaction().then((mysql.Transaction tran) {
      return tran.prepare("SELECT * FROM files").then((mysql.Query query) {
        return query.execute().then((result) {
          // Do something?
        }).then((_) {
          this._log.info("Closing");
          query.close();
        });
      }).then((_) {
        this._log.info("Rolling");
        return tran.rollback().then((_) {
          this._log.info("Rolled");
        });
      });
    });
  }
  
  Future _getMethod(RestRequest request) {
    return new Future.sync(() {
      int id = -1;
      if(request.regexMatch.group(1)!="") {
        try {
          id = int.parse(request.regexMatch.group(1));
        } on FormatException catch(e) {
          throw new RestException(HttpStatus.BAD_REQUEST,"File ids must be numeric");
        }
      }
      
      return this._model.getFiles(id).then((e) {
        Map<String, Object> output = new Map<String, Object>();
        output["files"] = e;
        return JSON.encode(output);
      });
    });
  }

  Future _postMethod(RestRequest request) {
    String data_string = request.getDataAsString();
    var temp = JSON.decode(data_string);
    if(!(temp is List)) {
      throw new RestException(HttpStatus.BAD_REQUEST,"Submitted data must contain a List of files");
    }
    List files = temp;
    for(Map file in files) {
      if(!file.containsKey("id")) {
        if(!file.containsKey("content_type")) {
          throw new RestException(HttpStatus.BAD_REQUEST,"One of the submitted files has no content type");
        };
        if(!file.containsKey("data")) {
          throw new RestException(HttpStatus.BAD_REQUEST,"One of the submitted files has no data");
        };
      }
    }
    
    return this._pool.startTransaction().then((mysql.Transaction tran) {
      return Future.forEach(files, (Map file) {
        if(file.containsKey("id")) {
          return _updateFile(file, tran);
        } else {
          return _createFile(file, tran);
        }
      }).then((e) {
        return tran.commit().then((_) {
          return e;
        });
      }).catchError((e, st) {
        this._log.severe(e.toString(), e, st);
        tran.rollback();
        throw e;
      });
    });
  }
  
  Future _createFile(Map file, mysql.Transaction tran) {
    return new Future.sync(() {
      ContentType ct = ContentType.parse(file["content_type"]);
      List<int> data = crypto.CryptoUtils.base64StringToBytes(file["data"]);
      List<String> tags = new List<String>();
      if(file.containsKey("tags")) {
        tags = file["tags"];
      }
      String name = null;
      if(file.containsKey("name")) {
        name = file["name"];
      }
      
      
      return this._model.createFile(data, tags, tran, name: name, ct: ct).then((e) {
        Map<String, Object> output = new Map<String, Object>();
        output["files"] = e;  
        return output;
      }).catchError((e) {
        if(e is EntityExistsException) {
          throw new RestException(HttpStatus.CONFLICT,"The submitted file already exists");
        } else {
          throw e;
        }
      });
    });
  }
  
  Future _updateFile(Map file, mysql.Transaction tran) {
    return new Future.sync(() {
      int id = int.parse(file["id"]);
      List<String> tags =new List<String>();
      if(file.containsKey("tags")) {
        tags = file["tags"];
      }
      String name = null;
      if(file.containsKey("name")) {
        name = file["name"];
      }
      
      return this._model.updateFile(id, tran, tags: tags, name: name);
    });
  }
}