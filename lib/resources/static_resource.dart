part of resources;

class StaticResource extends RestStaticFileResource {
  static const String _RESOURCE_PATH_REGEX = r'^/static/(.+)$';
  
  StaticResource(): super(_RESOURCE_PATH_REGEX,"static") {
    
  }
  
  @override
  String adjustFilePath(String filename) {
    if(filename.length>2) {
      return path.join(filename.substring(0,2),filename);
    } else {
      return filename;
    }
  }
}