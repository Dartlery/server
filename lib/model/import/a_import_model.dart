part of model;

abstract class AImportModel {
  FilesModel _filesModel;
  
  
  AImportModel() {
    this._filesModel = new FilesModel();
  }
  
  Future beginImport(mysql.Transaction tran, String host, String db, String user, String password, String image_folder, {int port: 3306});
  
}