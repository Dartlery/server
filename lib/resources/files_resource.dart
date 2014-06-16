part of resources;


class FilesResource extends RestResource {
  static const String _RESOURCE_PATH_REGEX = r'^/files/?$';

  //ADatabase _db;
  mysql.ConnectionPool _pool;
  
  FilesModel _model;

  FilesResource(this._pool): super(_RESOURCE_PATH_REGEX) {
    this._model = new FilesModel(this._pool);
    SetMethodHandler("GET", _GetMethod);
  }
  
  
  Future _GetMethod(ContentType type, String path, Map<String, String> args) {
    return this._model.GetAllFields().then((e) {
      Map<String, Object> output = new Map<String, Object>();
      output["files"] = e;
      return JSON.encode(output);
    });
  }

}