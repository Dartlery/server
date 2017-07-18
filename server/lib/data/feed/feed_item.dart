import 'package:rpc/rpc.dart';

import 'feed_attachment.dart';
import 'feed_author.dart';

class FeedItem {
  /// [id] (required, string) is unique for that item for that feed over time.
  /// If an item is ever updated, the [id] should be unchanged. New items should
  /// never use a previously-used [id]. If an [id] is presented as a number or
  /// other type, a JSON Feed reader must coerce it to a string. Ideally, the
  /// [id] is the full URL of the resource described by the item, since URLs
  /// make great unique identifiers.
  String id;

  /// [url] (optional, string) is the URL of the resource described by the item.
  /// It’s the permalink. This may be the same as the [id] — but should be
  /// present regardless.
  String url;

  /// [externalUrl] (very optional, string) is the URL of a page elsewhere.
  /// This is especially useful for linkblogs. If url links to where you’re
  /// talking about a thing, then [externalUrl] links to the thing you’re
  /// talking about.
  @ApiProperty(name: "external_url")
  String externalUrl;

  /// [title] (optional, string) is plain text. Microblog items in particular
  /// may omit titles.
  String title;

  /// [contentHtml] and [contentText] are each optional strings — but one or
  /// both must be present. This is the HTML or plain text of the item.
  /// Important: the only place HTML is allowed in this format is in
  /// [contentHtml]. A Twitter-like service might use [contentText], while a
  /// blog might use [contentHtml]. Use whichever makes sense for your resource.
  /// (It doesn’t even have to be the same for each item in a feed.)
  @ApiProperty(name: "content_html")
  String contentHtml;

  /// [contentHtml] and [contentText] are each optional strings — but one or
  /// both must be present. This is the HTML or plain text of the item.
  /// Important: the only place HTML is allowed in this format is in
  /// [contentHtml]. A Twitter-like service might use [contentText], while a
  /// blog might use [contentHtml]. Use whichever makes sense for your resource.
  /// (It doesn’t even have to be the same for each item in a feed.)
  @ApiProperty(name: "content_text")
  String contentText;

  /// [summary] (optional, string) is a plain text sentence or two describing
  /// the item. This might be presented in a timeline, for instance, where a
  /// detail view would display all of [contentHtml] or [contentText].
  String summary;

  /// [image] (optional, string) is the URL of the main image for the item.
  /// This image may also appear in the [contentHtml] — if so, it’s a hint to
  /// the feed reader that this is the main, featured image. Feed readers may
  /// use the image as a preview (probably resized as a thumbnail and placed
  /// in a timeline).
  String image;

  /// [bannerImage] (optional, string) is the URL of an image to use as a banner.
  /// Some blogging systems (such as Medium) display a different banner image
  /// chosen to go with each post, but that image wouldn’t otherwise appear in
  /// the [contentHtml]. A feed reader with a detail view may choose to show
  /// this banner image at the top of the detail view, possibly with the title
  /// overlaid.
  String bannerImage;

  /// [datePublished] (optional, string) specifies the date in RFC 3339 format.
  /// (Example: 2010-02-07T14:04:00-05:00.)
  DateTime datePublished;

  /// [dateModified] (optional, string) specifies the modification date in
  /// RFC 3339 format.
  DateTime dateModified;

  /// [author] (optional, [FeedAuthor]) has the same structure as the top-level
  /// [Feed.author]. If not specified in an item, then the top-level [Feed.author],
  /// if present, is the author of the item.
  FeedAuthor author;

  /// [tags] (optional, [List] of [String]) can have any plain text values you
  /// want. Tags tend to be just one word, but they may be anything. Note: they
  /// are not the equivalent of Twitter hashtags. Some blogging systems and
  /// other feed formats call these categories.
  List<String> tags;

  /// [attachments] (optional, [List] of [FeedAttachment]) lists related resources.
  /// Podcasts, for instance, would include an attachment that’s an audio or
  /// video file. Each attachment has several members:
  List<FeedAttachment> attachments;

  FeedItem(this.id,
      {this.url,
      this.externalUrl,
      this.title,
      this.contentHtml,
      this.contentText,
      this.summary,
      this.image,
      this.bannerImage,
      this.datePublished,
      this.dateModified,
      this.author,
      this.tags,
      this.attachments});
}
