part of model;

class FilesModel {
  final Logger _log = new Logger('FilesModel');
  
  mysql.ConnectionPool _pool;

  FilesModel(this._pool) {
    
  }
  
  
  Future GetAllFields() {
    this._log.info("Getting all files");
    
    return new Future.sync(() {
      List<Map> output = new List<Map>();      
    
      for(int i = 0; i < 5; i++) {
        Map<String,Object> file = new Map<String,Object>();
        file["id"] = i;
        file["source"] = "http://www.gravatar.com/avatar/bb56104632b355716a430ddef589fd15.png";
        file["thumbnail_source"] = "http://www.gravatar.com/avatar/bb56104632b355716a430ddef589fd15.png";
        List<String> tags = new List<String>();
        tags.add("tag1");
        tags.add("tag2");
        tags.add("tag3");
        tags.add("tag4");
        
        file["tags"] = tags;
        
        output.add(file);      
      }
      
      return output;
    });
  }  
}