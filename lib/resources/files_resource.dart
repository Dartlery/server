part of resources;


class FilesResource extends RestResource {
  static const String _RESOURCE_PATH_REGEX = r'^/files/?$';

  //ADatabase _db;
  mysql.ConnectionPool _pool;
  
  FilesModel _model;

  FilesResource(this._pool): super(_RESOURCE_PATH_REGEX) {
    this._model = new FilesModel(this._pool);
    setMethodHandler("GET", _GetMethod);
    setMethodHandler("POST", _PostMethod);
  }
  
  
  Future _GetMethod(RestRequest request) {
    return this._model.GetAllFiles().then((e) {
      Map<String, Object> output = new Map<String, Object>();
      output["files"] = e;
      return JSON.encode(output);
    });
  }

  Future _PostMethod(RestRequest request) {
    return this._model.CreateFile(request.dataContentType, request.data).then((e) {
      Map<String, Object> output = new Map<String, Object>();
      output["files"] = e;
      return JSON.encode(output);
    }).catchError((e) {
      if(e is EntityExistsException) {
        throw new RestException(HttpStatus.CONFLICT,"The submitted file already exists");
      } else {
        throw e;
      }
    });
  }
}