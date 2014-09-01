part of resources;

class ImportResource extends RestResource {
  static final Logger _log = new Logger('ImportResource');
  
  static const String _RESOURCE_PATH_REGEX = r'^/import/([^/]*)/?$';

  List<String> _supportedImporters = new List<String>();
  
  mysql.ConnectionPool _pool;
  
  ImportResource(this._pool): super(_RESOURCE_PATH_REGEX) {
    this._supportedImporters.add("shimmie");
    
    setMethodHandler(HttpMethod.GET, _getMethod);
    setMethodHandler(HttpMethod.POST, _postMethod);
    this.addAcceptableContentType(ContentType.JSON,HttpMethod.POST);
  }
  
  
  Future _getMethod(RestRequest request) {
    return new Future(() {
      Map output = new Map();
      output["importers"] = this._supportedImporters;
      return JSON.encode(output);
    });
  }
  
  Future _postMethod(RestRequest request) {
    return new Future(() {
      String data_string = request.getDataAsString();
      var temp; 
      try {
        temp = JSON.decode(data_string);
      } catch(e) {
        throw new RestException(HttpStatus.BAD_REQUEST,"Submitted data was not valid JSON");
      }
      if(!(temp is Map)) {
        throw new RestException(HttpStatus.BAD_REQUEST,"Submitted data must contain a Map of import settings");
      }
      Map data = temp;
      if(!data.containsKey("host")) {
        throw new RestException(HttpStatus.BAD_REQUEST,"Submitted data must contain a host");
      }
      if(!data.containsKey("db")) {
        throw new RestException(HttpStatus.BAD_REQUEST,"Submitted data must contain a db");
      }
      if(!data.containsKey("user")) {
        throw new RestException(HttpStatus.BAD_REQUEST,"Submitted data must contain a user");
      }
      if(!data.containsKey("password")) {
        throw new RestException(HttpStatus.BAD_REQUEST,"Submitted data must contain a password");
      }
      if(!data.containsKey("image_folder")) {
        throw new RestException(HttpStatus.BAD_REQUEST,"Submitted data must contain an image_folder");
      }
      
      ShimmieImportModel model =  new ShimmieImportModel();
      
      return this._pool.startTransaction().then((mysql.Transaction tran) {
        return model.beginImport(tran, data["host"], data["db"], data["user"], data["password"], data["image_folder"]).then((_) {
          _log.info("Importing complete, committing");
          return tran.commit();
        }).catchError((e, st) {
          _log.severe(e.toString(), e, st);
          return tran.rollback().then((_) {
            throw e;
          });
        });
      });
      
    });
  } 

}