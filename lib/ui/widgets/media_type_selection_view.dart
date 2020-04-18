import 'package:flutter/material.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';

class MediaTypeSelectionView extends StatefulWidget {

  final List<AdType> adTypes;
  final ValueChanged<AdType> onSelected;

  MediaTypeSelectionView({this.adTypes, this.onSelected});

  @override
  _MediaTypeSelectionViewState createState() => _MediaTypeSelectionViewState();
}

class _MediaTypeSelectionViewState extends State<MediaTypeSelectionView> {
  AdType _selectedAdType;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 1,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(5),
        children: List.generate(widget.adTypes.length, (int index) {
            final adType = widget.adTypes[index];
            return GestureDetector(
              child: _buildItem(adType),
              onTap: () {
                setState(() {
                  _selectedAdType = adType;
                  widget.onSelected(_selectedAdType);
                });
              },
            );
        })
    );
  }

  Widget _buildItem(AdType adType) {
    bool isSelected = _selectedAdType == adType;
    return Card(
      color: isSelected ? goldColor : Colors.white70,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: _getPreview(adType),
                )
            ),
            Container(
              padding: EdgeInsets.all(5),
              alignment: Alignment.center,
              child: Text(
                _getTypeName(adType),
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeName(AdType adType) {
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

  Widget _getPreview(AdType adType) {
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
