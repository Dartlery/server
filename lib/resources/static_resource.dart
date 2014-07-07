part of resources;

class StaticResource extends RestStaticFileResource {
  static const String _RESOURCE_PATH_REGEX = r'^/static/(.+)$';
  
  StaticResource(): super(_RESOURCE_PATH_REGEX,"static") {
    
  }
  
  @override
  String adjustFilePath(String filename) {
    if(filename.length>2) {
      
      
      return path.join(path.dirname(filename),path.basename(filename).substring(0,2),path.basename(filename));
    } else {
      return filename;
    }
  }
}