part of resources;

class StaticResource extends RestStaticFileResource {
  static const String _RESOURCE_PATH_REGEX = r'^/static/(.+)$';
  
  StaticResource(): super(_RESOURCE_PATH_REGEX,"static") {
    
  }
}