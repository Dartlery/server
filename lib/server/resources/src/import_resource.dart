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
  
  
  _getMethod(RestRequest request) async {
    Map output = new Map();
    output["importers"] = this._supportedImporters;
    return JSON.encode(output);
  }
  
  _postMethod(RestRequest request) async {
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
    
    mysql.Transaction tran = await this._pool.startTransaction();
    try {
      await model.beginImport(tran, data["host"], data["db"], data["user"], data["password"], data["image_folder"]);
      _log.info("Importing complete, committing");
      await tran.commit();
    } catch(e, st) {
      _log.severe(e.toString(), e, st);
      await tran.rollback();
      throw e;
    }
      
      
  } 

}