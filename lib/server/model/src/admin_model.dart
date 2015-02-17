part of model;

class AdminModel {
  mysql.ConnectionPool _pool;
  
  AdminModel(this._pool) {
    
  }
  
  recreateAllThumbnails() async {
    mysql.Query query = await this._pool.prepare("SELECT COUNT(*) AS count FROM files WHERE hash = ?");
    dynamic results = await query.execute([hash]);
    
      return results.forEach((row) {
        if(row.count>0) {
          throw new EntityExistsException(hash_string);
        }
    });
  }
}