part of resources;


class FilesResource extends RestResource {
  static final Logger _log = new Logger('FilesResource');
  
  static const String _RESOURCE_PATH_REGEX = r'^/files/([^/]*)/?$';

  mysql.ConnectionPool _pool;
  
  FilesResource(this._pool): super(_RESOURCE_PATH_REGEX) {
    setMethodHandler(HttpMethod.GET, _getMethod);
    setMethodHandler(HttpMethod.POST, _postMethod);
    setMethodHandler(HttpMethod.PUT, _putMethod);
    this.addAcceptRange("files");
    this.addAcceptableContentType(ContentType.JSON,HttpMethod.POST);
  }
  
  
    Future _putMethod(RestRequest request) {
      return new Future.sync(() {
          return _pool.prepare("SELECT name FROM files").then((mysql.Query query) {
            return query.execute().then((result) {
              // Do something?
              return result.toList();
            }).then((_) {
              _log.info("Closing");
              query.close();
            });
          }).then((_) {
            _pool.close();
          });
      });
    }
  
  
  Future _getMethod(RestRequest request) {
    return new Future.sync(() {
      FilesModel model = new FilesModel();
      int id = -1;
      if(request.regexMatch.group(1)!="") {
        try {
          id = int.parse(request.regexMatch.group(1));
        } on FormatException catch(e) {
          throw new RestException(HttpStatus.BAD_REQUEST,"File ids must be numeric");
        }
      }
      
      int limit = 30;
      int offset = 0;
      String search;
      List<String> sort = new List<String>();
      List<String> expand = new List<String>();
      
      if(request.range!=null) {
        offset = request.range.start;
        limit = request.range.count;
        if(limit>SettingsModel.maxFilesReturned) {
          limit = SettingsModel.maxFilesReturned;
        }
      }
      
      if(request.args.containsKey("search")) {
        search = request.args["search"];
      }
      
      if(request.args.containsKey("sort")&&request.args["sort"]!="") {
        sort.addAll(request.args["sort"].split("|"));
      }
      
      if(request.args.containsKey("expand")) {
        expand.addAll(request.args["expand"].split(","));
      }


      return _pool.getConnection().then((mysql.RetainedConnection con) {
        return model.getFiles(con, id: id, limit: limit, offset: offset, search: search, order_by: sort, expand: expand).then((e) {
          Map<String, Object> output = new Map<String, Object>();
          output["files"] = e["files"];
          
          if(e["count"]>0) {
            List files = output["files"]; 
            if(request.range!=null) {
              if(files.length==0) {
                request.response.httpResponse.headers.add(HttpHeaders.CONTENT_RANGE, "files ${SettingsModel.maxFilesReturned}/${e['count']-1}");
                throw new RestException(HttpStatus.REQUESTED_RANGE_NOT_SATISFIABLE,"The requested range could not be satisfied");
              }
              request.response.setRange("files", request.range.start, request.range.start + files.length - 1, e["count"] - 1);
            } else {
              request.response.setRange("files", 0, files.length - 1, e["count"] - 1);
            }
          }
          
          return JSON.encode(output);
        }).whenComplete(() {
          con.release();
        });
      }).catchError((e,st) {
        if(e is ValidationException) {
          throw new RestException(HttpStatus.BAD_REQUEST, e.message);
        } else {
          throw e;
        }
      });
    });
  }

  Future _postMethod(RestRequest request) {
    return new Future.sync(() {
      String data_string = request.getDataAsString();
      var temp = JSON.decode(data_string);
      if(!(temp is List)) {
        throw new RestException(HttpStatus.BAD_REQUEST,"Submitted data must contain a List of files");
      }
      List files = temp;
      for(Map file in files) {
        if(!file.containsKey("id")) {
          if(!file.containsKey("content_type")) {
            throw new RestException(HttpStatus.BAD_REQUEST,"One of the submitted files has no content type");
          };
          if(!file.containsKey("data")) {
            throw new RestException(HttpStatus.BAD_REQUEST,"One of the submitted files has no data");
          };
        }
      }
      
      return _pool.startTransaction().then((mysql.Transaction tran) {
        return Future.forEach(files, (Map file) {
          if(file.containsKey("id")) {
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
    return new Future.sync(() {
      ContentType ct = ContentType.parse(file["content_type"]);
      List<int> data = crypto.CryptoUtils.base64StringToBytes(file["data"]);
      List<String> tags = new List<String>();
      if(file.containsKey("tags")) {
        tags = file["tags"];
      }
      String name = null;
      if(file.containsKey("name")) {
        name = file["name"];
      }
      
      FilesModel model = new FilesModel();

      return model.createFile(data, tags, tran, name: name, ct: ct).then((e) {
        Map<String, Object> output = new Map<String, Object>();
        output["files"] = e;  
        return output;
      }).catchError((e) {
        if(e is EntityExistsException) {
          throw new RestException(HttpStatus.CONFLICT,"The submitted file already exists");
        } else {
          throw e;
        }
      });
    });
  }
  
  Future _updateFile(Map file, mysql.Transaction tran) {
    return new Future.sync(() {
      int id = int.parse(file["id"]);
      List<String> tags =new List<String>();
      if(file.containsKey("tags")) {
        tags = file["tags"];
      }
      String name = null;
      if(file.containsKey("name")) {
        name = file["name"];
      }

      FilesModel model = new FilesModel();

      return model.updateFile(id, tran, tags: tags, name: name);
    });
  }
}