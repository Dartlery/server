part of resources;


class TagsResource extends RestResource {
  static final Logger _log = new Logger('TagsResource');

  static const String _RESOURCE_PATH_REGEX = r'^/tags/$';


  final mysql.ConnectionPool _pool;

  TagsResource(this._pool) : super(_RESOURCE_PATH_REGEX) {
    setMethodHandler(HttpMethod.GET, _getMethod);
    this.addAcceptRange("tags");
  }

  _getMethod(RestRequest request) async {
    int limit = 50;
    List<String> order_by = new List<String>();
    List<String> expand = new List<String>();
    
    if(request.range!=null) {
      if(request.range.start!=0) {
        throw new RestException(HttpStatus.BAD_REQUEST,"When requesting a range for top tags the start must be 0");
      } else {
        limit = request.range.count;
      }
    }
    if(request.args.containsKey("expand")) {
      expand.addAll(request.args["expand"].split(","));
    }
    if(request.args.containsKey("sort")) {
      order_by.addAll(request.args["sort"].split(","));
    }
    
    mysql.RetainedConnection con = await _pool.getConnection();
    try {
      Map output = await TagsModel.getTags(con, limit: limit, order_by: order_by, expand: expand);
      if(output["count"]>0) {
        request.response.setRange("tags", 0, limit-1, output["count"]-1);
      }
      return JSON.encode(output["tags"]);
    } on ValidationException catch(e,st) {
      throw new RestException(HttpStatus.BAD_REQUEST, e.message);
    } finally {
      con.release();
    }
  }

}
