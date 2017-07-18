class InvalidInputException implements Exception {
  final String message;
  InvalidInputException(this.message);

  @override
  String toString() {
    return message;
  }
}
