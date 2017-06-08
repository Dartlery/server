
/// Object representing the author of a feed.
class FeedAuthor {
  /// [name] (optional, string) is the author’s name.
  String name;

  /// [url] (optional, string) is the URL of a site owned by the author. It
  /// could be a blog, micro-blog, Twitter account, and so on. Ideally the
  /// linked-to page provides a way to contact the author, but that’s not
  /// required. The URL could be a mailto: link, though we suspect that
  /// will be rare.
  String url;

  /// [avatar] (optional, string) is the URL for an image for the author.
  /// As with [Feed.icon], it should be square and relatively large — such
  /// as 512 x 512 — and should use transparency where appropriate,
  /// since it may be rendered on a non-white background.
  String avatar;

  FeedAuthor({this.name, this.url, this.avatar});
}
