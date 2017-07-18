import 'dart:io';

class ForbiddenException implements Exception {
  final String message;
  final int code = HttpStatus.FORBIDDEN;

  ForbiddenException([this.message = "Forbidden"]);

  @override
  String toString() {
    return message;
  }
}
