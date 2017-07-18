import 'package:rpc/rpc.dart';

import 'feed_author.dart';
import 'feed_hub.dart';
import 'feed_item.dart';

export 'feed_author.dart';
export 'feed_hub.dart';
export 'feed_item.dart';

/// Class for generating output compliant with https://jsonfeed.org/version/1
class Feed {
  /// [version] (required, string) is the URL of the version of the format the feed uses. This should appear at the very top, though we recognize that not all JSON generators allow for ordering.
  final String version = "https://jsonfeed.org/version/1";

  /// [title] (required, string) is the name of the feed, which will often correspond to the name of the website (blog, for instance), though not necessarily.
  String title;

  /// [homePageUrl] (optional but strongly recommended, string) is the URL of the resource that the feed describes. This resource may or may not actually be a “home” page, but it should be an HTML page. If a feed is published on the public web, this should be considered as required. But it may not make sense in the case of a file created on a desktop computer, when that file is not shared or is shared only privately.
  @ApiProperty(name: "home_page_url")
  String homePageUrl;

  /// [feedUrl] (optional but strongly recommended, string) is the URL of the feed, and serves as the unique identifier for the feed. As with [homePageUrl], this should be considered required for feeds on the public web.
  @ApiProperty(name: "feed_url")
  String feedUrl;

  /// [description] (optional, string) provides more detail, beyond the [title], on what the feed is about. A feed reader may display this text.
  String description;

  /// [userComment] (optional, string) is a description of the purpose of the feed. This is for the use of people looking at the raw JSON, and should be ignored by feed readers.
  @ApiProperty(name: "user_comment")
  String userComment;

  /// [nextUrl] (optional, string) is the URL of a feed that provides the next n items, where n is determined by the publisher. This allows for pagination, but with the expectation that reader software is not required to use it and probably won’t use it very often. [nextUrl] must not be the same as [feedUrl], and it must not be the same as a previous [nextUrl] (to avoid infinite loops).
  @ApiProperty(name: "next_url")
  String nextUrl;

  /// [icon] (optional, string) is the URL of an image for the feed suitable to be used in a timeline, much the way an avatar might be used. It should be square and relatively large — such as 512 x 512 — so that it can be scaled-down and so that it can look good on retina displays. It should use transparency where appropriate, since it may be rendered on a non-white background.
  String icon;

  /// [favicon] (optional, string) is the URL of an image for the feed suitable to be used in a source list. It should be square and relatively small, but not smaller than 64 x 64 (so that it can look good on retina displays). As with [icon], this image should use transparency where appropriate, since it may be rendered on a non-white background.
  String favicon;

  /// [author] (optional, [FeedAuthor]) specifies the feed author. The author object has several members. These are all optional — but if you provide an author object, then at least one is required:
  FeedAuthor author;

  /// [expired] (optional, boolean) says whether or not the feed is finished — that is, whether or not it will ever update again. A feed for a temporary event, such as an instance of the Olympics, could expire. If the value is true, then it’s expired. Any other value, or the absence of [expired], means the feed may continue to update.
  bool expired;

  /// [hubs] (very optional, [List] of [FeedHub]) describes endpoints that can be used to subscribe to real-time notifications from the publisher of this feed. Each object has a type and url, both of which are required. See the section “Subscribing to Real-time Notifications” below for details.
  List<FeedHub> hubs;

  final List<FeedItem> items = <FeedItem>[];

  Feed(this.title,
      {this.homePageUrl,
      this.feedUrl,
      this.description,
      this.userComment,
      this.nextUrl,
      this.icon,
      this.favicon,
      this.author,
      this.expired,
      this.hubs});
}
