part of model;

class EntityExistsException implements  Exception {
  String message;
  EntityExistsException(this.message);
}