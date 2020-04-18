import 'package:flutter/material.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';

class MediaTypeItem extends StatelessWidget {
  final AdType adType;

  MediaTypeItem({
    @required this.adType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: FittedBox(
              fit: BoxFit.fill,
              child: _getPreview(),
            )
        ),
        Text(_getTypeName()),
      ],
    );
  }

  String _getTypeName() {
    if (adType == AdType.imageAd) {
      return '画像';
    } else if (adType == AdType.videoAd) {
      return '動画';
    } else if (adType == AdType.rssAd) {
      return 'RSS';
    } else if (adType == AdType.multiAd) {
      return '複数';
    } else {
      throw ArgumentError("invalid adType: $adType");
    }
  }

  Widget _getPreview() {
    if (adType == AdType.imageAd) {
      return Icon(Icons.image);
    } else if (adType == AdType.videoAd) {
      return Icon(Icons.video_library);
    } else if (adType == AdType.rssAd) {
      return Icon(Icons.rss_feed);
    } else if (adType == AdType.multiAd) {
      return Row(
        children: [
          Column(
            children: [
              Icon(
                Icons.image
              ),
              Icon(
                  Icons.image
              ),
            ],
          ),
          Column(
            children: [
              Icon(
                  Icons.image
              ),
              Icon(
                  Icons.image
              ),
            ],
          )
        ],
      );
    } else {
      throw ArgumentError("invalid adType: $adType");
    }
  }
}
