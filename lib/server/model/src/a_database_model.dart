part of model;

abstract class ADatabaseModel extends AModel {
  mysql.ConnectionPool _pool;
  
  ADatabaseModel(this._pool);
  
  
  Future<mysql.Query> _prepare(String sql, {mysql.Transaction transaction:null}) {
    if(transaction==null) {
      return this._pool.prepare(sql);
    } else {
      return transaction.prepare(sql);
    }
  }
}