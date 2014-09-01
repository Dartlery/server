part of resources;


class TagGroupsResource extends RestResource {
  static final Logger _log = new Logger('TagGroupsResource');

  static const String _RESOURCE_PATH_REGEX = r'^/tag_groups/([^/]*)/?$';

  mysql.ConnectionPool _pool;

  TagGroupsResource(this._pool) : super(_RESOURCE_PATH_REGEX) {
    setMethodHandler(HttpMethod.GET, _getMethod);
    setMethodHandler(HttpMethod.POST, _postMethod);
    this.addAcceptableContentType(ContentType.JSON, HttpMethod.POST);
  }

  Future _getMethod(RestRequest request) {
    return new Future(() {
      TagGroupsModel model = new TagGroupsModel();
      String name = null;
      if (request.regexMatch.group(1) != "") {
        name = request.regexMatch.group(1);
      }

      return _pool.getConnection().then((mysql.RetainedConnection con) {
        return new Future(() {
          if (name == null) {
            return model.getGroups(con);
          }
        }).then((output) {
          return JSON.encode(output);
        }).whenComplete(() {
          con.release();
        });
      }).catchError((e, st) {
        if (e is ValidationException) {
          throw new RestException(HttpStatus.BAD_REQUEST, e.message);
        } else {
          throw e;
        }
      });
    });
  }

  Future _postMethod(RestRequest request) {
    return new Future(() {
      String data_string = request.getDataAsString();
      var temp = JSON.decode(data_string);
      if (!(temp is List)) {
        throw new RestException(HttpStatus.BAD_REQUEST, "Submitted data must contain a List of files");
      }
      List files = temp;
      for (Map file in files) {
        if (!file.containsKey("id")) {
          if (!file.containsKey("content_type")) {
            throw new RestException(HttpStatus.BAD_REQUEST, "One of the submitted files has no content type");
          }
          ;
          if (!file.containsKey("data")) {
            throw new RestException(HttpStatus.BAD_REQUEST, "One of the submitted files has no data");
          }
          ;
        }
      }

      return _pool.startTransaction().then((mysql.Transaction tran) {
        return Future.forEach(files, (Map file) {
          if (file.containsKey("id")) {
            return _updateFile(file, tran);
          } else {
            return _createFile(file, tran);
          }
        }).then((e) {
          return tran.commit().then((_) {
            return e;
          });
        }).catchError((e, st) {
          _log.severe(e.toString(), e, st);
          return tran.rollback().then((_) {
            throw e;
          });
        });
      });
    });
  }

  Future _createFile(Map file, mysql.Transaction tran) {
    return new Future(() {
      ContentType ct = ContentType.parse(file["content_type"]);
      List<int> data = crypto.CryptoUtils.base64StringToBytes(file["data"]);
      List<String> tags = new List<String>();
      if (file.containsKey("tags")) {
        tags = file["tags"];
      }
      String name = null;
      if (file.containsKey("name")) {
        name = file["name"];
      }

      FilesModel model = new FilesModel();

      return model.createFile(data, tags, tran, name: name, ct: ct).then((e) {
        Map<String, Object> output = new Map<String, Object>();
        output["files"] = e;
        return output;
      }).catchError((e) {
        if (e is EntityExistsException) {
          throw new RestException(HttpStatus.CONFLICT, "The submitted file already exists");
        } else {
          throw e;
        }
      });
    });
  }

  Future _updateFile(Map file, mysql.Transaction tran) {
    return new Future(() {
      int id = int.parse(file["id"]);
      List<String> tags = new List<String>();
      if (file.containsKey("tags")) {
        tags = file["tags"];
      }
      String name = null;
      if (file.containsKey("name")) {
        name = file["name"];
      }

      FilesModel model = new FilesModel();

      return model.updateFile(id, tran, tags: tags, name: name);
    });
  }
}
