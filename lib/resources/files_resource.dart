part of resources;


class FilesResource extends RestResource {
  static const String _RESOURCE_PATH_REGEX = r'^/files/?$';

  //ADatabase _db;
  mysql.ConnectionPool _pool;
  
  FilesModel _model;

  FilesResource(this._pool): super(_RESOURCE_PATH_REGEX) {
    this._model = new FilesModel(this._pool);
    setMethodHandler("GET", _getMethod);
    setMethodHandler("POST", _postMethod);
    this.addAcceptableContentType(ContentType.JSON,HttpMethod.POST);
  }
  
  
  Future _getMethod(RestRequest request) {
    return this._model.GetAllFiles().then((e) {
      Map<String, Object> output = new Map<String, Object>();
      output["files"] = e;
      return JSON.encode(output);
    });
  }

  Future _postMethod(RestRequest request) {
    String data_string = request.getDataAsString();
    List files = JSON.decode(data_string);
    for(Map file in files) {
      if(!file.containsKey("content_type")) {
        throw new RestException(HttpStatus.BAD_REQUEST,"One of the submitted files has no content type");
      };
      if(!file.containsKey("data")) {
        throw new RestException(HttpStatus.BAD_REQUEST,"One of the submitted files has no data");
      };
    }
    
    return Future.forEach(files, _createFile).then((e) {
      return e;
    });
  }
  
  Future _createFile(Map file) {
    return new Future.sync(() {
      ContentType ct = ContentType.parse(file["content_type"]);
      List<int> data = crypto.CryptoUtils.base64StringToBytes(file["data"]);
      String tags = "";
      if(file.containsKey("tags")) {
        tags = file["tags"];
      }
      
      return this._model.CreateFile(ct, data,tags).then((e) {
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
  
}