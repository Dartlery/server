import 'package:polymer/builder.dart';

void main(List<String> args) {
  lint(entryPoints: ['web/dartlery.html'], options: parseOptions(args));
}