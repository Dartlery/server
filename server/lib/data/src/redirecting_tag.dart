import 'tag.dart';
import 'package:rpc/rpc.dart';

class RedirectingTag extends Tag {
  @ApiProperty(ignore: true)
  Tag redirect; // Only here so that the API will generate it as a field

}