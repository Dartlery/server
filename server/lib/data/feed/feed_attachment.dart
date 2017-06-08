import 'package:rpc/rpc.dart';

class FeedAttachment {
  /// [url] (required, string) specifies the location of the attachment.
  String url;

  /// [mimeType] (required, string) specifies the type of the attachment,
  /// such as “audio/mpeg.”
  @ApiProperty(name: "mime_type")
  String mimeType;

  /// [title] (optional, string) is a name for the attachment. Important: if
  /// there are multiple attachments, and two or more have the exact same
  /// [title] (when [title] is present), then they are considered as alternate
  /// representations of the same thing. In this way a podcaster, for instance,
  /// might provide an audio recording in different formats.
  String title;

  /// [sizeInBytes] (optional, number) specifies how large the file is.
  @ApiProperty(name: "size_in_bytes")
  int sizeInBytes;

  /// [durationInSeconds] (optional, number) specifies how long it takes to
  /// listen to or watch, when played at normal speed.
  @ApiProperty(name: "duration_in_seconds")
  int durationInSeconds;

  FeedAttachment(this.url, this.mimeType,
      {this.title, this.sizeInBytes, this.durationInSeconds});
}
