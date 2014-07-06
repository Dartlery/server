part of resources;

class AdminResource extends RestResource {
  static const String _RESOURCE_PATH_REGEX = r'^/admin/?$';

  mysql.ConnectionPool _pool;
  
  AdminModel _model;

  AdminResource(this._pool): super(regex: _RESOURCE_PATH_REGEX) {
    this._model = new AdminModel(this._pool);
    setMethodHandler("GET", _getMethod);
  }
  
  
  Future _getMethod(RestRequest request) {
    return new Future.sync(() {});
  } 
}