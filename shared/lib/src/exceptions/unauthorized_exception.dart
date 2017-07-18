import 'dart:io';

class UnauthorizedException implements Exception {
  final String message;

  final int code = HttpStatus.UNAUTHORIZED;

  UnauthorizedException([this.message = "Not authorized"]);

  @override
  String toString() {
    return message;
  }
}
