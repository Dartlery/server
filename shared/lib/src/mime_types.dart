class MimeTypes {
  static const Map<String, String> extensions = const <String, String>{
    asf: "asf",
    avi: "avi",
    flv: "flv",
    gif: "gif",
    jpeg: "jpg",
    mkv: "mkv",
    mpeg: "mpeg",
    mp4: "mp4",
    openExr: "exr",
    pdf: "pdf",
    png: "png",
    psd: "psd",
    pvr: "pvr",
    quicktime: "mov",
    swf: "swf",
    tiff: "tiff",
    tga: "tga",
    webp: "webp",
    webm: "webm",
  };

  static const String jpeg = "image/jpeg";
  static const String gif = "image/gif";
  static const String png = "image/png";
  static const String tga = "image/targa";
  static const String tiff = "image/tiff";
  static const String webp = "image/webp";
  static const String psd = "image/vnd.adobe.photoshop";
  static const String pvr = "image/x-pvr";
  static const String openExr = "image/x-exr";

  static const String webm = 'video/webm';
  static const String mp4 = 'video/mp4';
  static const String flv = 'video/x-flv';
  static const String quicktime = 'video/quicktime';
  static const String avi = 'video/avi';
  static const String asf = 'video/x-ms-asf';
  static const String mpeg = 'video/mpeg';
  static const String mkv = 'video/x-matroska';
  static const String swf = "application/x-shockwave-flash";

  static const String pdf = "application/pdf";

  static const List<String> animatableImageTypes = const <String>[
    gif,
    png,
    webp
  ];

  static const List<String> imageTypes = const <String>[
    jpeg,
    gif,
    png,
    tga,
    tiff,
    webp,
    psd,
    pvr,
    openExr
  ];

  static const List<String> losslessTypes = const <String>[
    png,
    tiff,
    psd
  ];

  static const List<String> webFriendlyTypes = const <String>[
    jpeg,
    gif,
    png,
    webp,
    webm,
    mp4,
    swf,
  ];

  static const List<String> videoTypes = const <String>[
    webm,
    mp4,
    flv,
    quicktime,
    avi,
    asf,
    mpeg,
    mkv
  ];
}
