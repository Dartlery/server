part of model;

class AdminModel {
  mysql.ConnectionPool _pool;
  
  AdminModel(this._pool) {
    
  }
  
  Future recreateAllThumbnails() {
    return this._pool.prepare("SELECT COUNT(*) AS count FROM files WHERE hash = ?").then((query) {
      return query.execute([hash]).then((results) {
        return results.forEach((row) {
          if(row.count>0) {
            throw new EntityExistsException(hash_string);
          }
        }); 
      });
    });
  }
}