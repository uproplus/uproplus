
class Ad {
  String id;
  String owner;
  AdType adType;
  String mediaPath;
  String thumbnailPath;
  int duration;
  String text;
  int order;
  List<Ad> childAds = [];

  Ad({
    this.adType,
    this.owner,
    this.mediaPath,
    this.thumbnailPath,
    this.duration,
    this.text,
    this.order,
  });

  Ad.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    owner =  map['owner'];
    adType = AdType.toType(map['type']);
    mediaPath = map['media_path'];
    thumbnailPath = map['thumbnail_path'];
    duration = map['duration'];
    text = map['ad_text'];
    order = map['ad_order'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['owner'] = this.owner;
    data['type'] = this.adType.toDbValue();
    data['media_path'] = this.mediaPath;
    data['thumbnail_path'] = this.thumbnailPath;
    data['duration'] = this.duration;
    data['ad_text'] = this.text;
    data['ad_order'] = this.order;
    return data;
  }
}

abstract class AdType {
  AdType._();

  static const imageAd = const ImageAd();
  static const videoAd = const VideoAd();
  static const rssAd = const RssAd();
  static const multiAd = const MultiAd();

  static AdType toType(String dbValue) {
    switch (dbValue) {
      case ImageAd.DB_VALUE:
        return imageAd;
      case VideoAd.DB_VALUE:
        return videoAd;
      case RssAd.DB_VALUE:
        return rssAd;
      case MultiAd.DB_VALUE:
        return multiAd;
      default:
        throw ArgumentError("invalid AdType dbValue: $dbValue");
    }
  }

  String toDbValue();
}

class ImageAd implements AdType {
  static const String DB_VALUE = "image_ad";
  const ImageAd();

  @override
  String toDbValue() {
    return DB_VALUE;
  }
}

class VideoAd implements AdType {
  static const String DB_VALUE = "video_ad";
  const VideoAd();

  @override
  String toDbValue() {
    return DB_VALUE;
  }
}

class MultiAd implements AdType {
  static const String DB_VALUE = "multi_ad";
  const MultiAd();

  @override
  String toDbValue() {
    return DB_VALUE;
  }
}

class RssAd implements AdType {
  static const String DB_VALUE = "rss_ad";
  const RssAd();

  @override
  String toDbValue() {
    return DB_VALUE;
  }
}

