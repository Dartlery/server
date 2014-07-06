part of model;

class EntityExistsException implements  Exception {
  String message;
  EntityExistsException(this.message);
}

class FileTypeNotSupportedException implements  Exception {
  String message;
  FileTypeNotSupportedException(this.message);
}
