part of resources;

class RootResource extends RestResource {
  static const String _RESOURCE_PATH_REGEX = r'^/?$';

  RootResource(): super(_RESOURCE_PATH_REGEX) {
    setMethodHandler("GET", this._getMethod);

  }

  Future _getMethod(RestRequest request) {
    return new Future(() {
      List<Object> links = new List<Object>();

//      JsonSchemaLink link = new JsonSchemaLink(SCHEMA_LINK_GET_FIELDS, "/fields/");
//      link.Title = "List all fields";
//      links.add(link.toJson());
//      links.addAll(FieldsResource._JSON_LINKS);
//
//      link = new JsonSchemaLink(SCHEMA_LINK_GET_CLASSES, "/classes/");
//      link.Title = "List all classes";
//      links.add(link.toJson());
//
//      link = new JsonSchemaLink(SCHEMA_LINK_GET_OBJECTS, "/objects/");
//      link.Title = "List all objects";
//      links.add(link.toJson());
//
//      links.add(SettingsResource.GET_LINK.toJson());
//
//      links.add(NukeResource.DELETE_LINK.toJson());

      
      return; //_PrepareOutput(request.requestedContentType, links: links);
    });
  }
}
