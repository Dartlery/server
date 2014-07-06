part of model;

abstract class AImportModel {
  mysql.ConnectionPool _pool;
  FilesModel _filesModel;
  
  
  AImportModel(this._pool) {
    this._filesModel = new FilesModel(this._pool);
  }
  
  Future beginImport(String host, String db, String user, String password, String image_folder, {int port: 3306});
  
}