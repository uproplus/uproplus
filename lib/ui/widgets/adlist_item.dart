import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/shared/text_styles.dart';
import 'package:validators/validators.dart';

class AdListItem extends StatelessWidget {
  final Ad ad;
  final Function onTap;

  AdListItem({this.ad, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
//          margin: EdgeInsets.all(5.0),
          width: _viewWidth(context),
          height: _viewHeight(context),
          color: adMediaBackgroundColor,
          child: _getPreview(ad),
        ),
      ),
    );
  }

  Widget _getPreview(Ad ad) {
    if (ad.adType == AdType.imageAd) {
      return Row(
        children: [
          Expanded(
            child: _getThumbnailPreview(_getThumbnailPath(ad)),
          ),
          _isNullOrEmpty(ad.text) ? Container() :
          Expanded(
            child: Container(
              color: Colors.white,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(5),
              child: Text(
                ad.text == null ? "" : ad.text,
                textAlign: TextAlign.left,
                style: adPreviewTextStyle,
              ),
            ),
          )
        ],
      );
    } else if (ad.adType == AdType.videoAd) {
      return Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 3.0,
                          offset: Offset(0.0, 2.0),
                          color: Color.fromARGB(80, 0, 0, 0))
                    ]),
                child: _getThumbnailPreview(_getThumbnailPath(ad)),
              ),
            ),
            _isNullOrEmpty(ad.text) ? Container() :
            Expanded(
              child: Container(
                color: Colors.white,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(5),
                child: Text(
                  ad.text == null ? "" : ad.text,
                  textAlign: TextAlign.left,
                  style: adPreviewTextStyle,
                ),
              ),
            )
          ]
      );
    } else if (ad.adType == AdType.rssAd) {
      return Row(
        children: [
          _isNullOrEmpty(_getThumbnailPath(ad)) ? Container() :
          Expanded(
            child: Container(
              color: Colors.black,
              child: _getThumbnailPreview(_getThumbnailPath(ad)),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(5),
              child: Text(
                ad.text == null ? "" : ad.text,
                textAlign: TextAlign.left,
                style: adPreviewTextStyle,
              ),
            ),
          )
        ],
      );
    } else if (ad.adType == AdType.multiAd) {
      if (ad.childAds.isEmpty) {
        return Row(
          children: [
            Expanded(
              child: Text("No ads"),
            )
          ],
        );
      } else if (ad.childAds.length == 1) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 3.0)
          ),
          child: _getPreview(ad.childAds[0]),
        );
      } else if (ad.childAds.length == 2) {
        return Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 3.0)
          ),
          child: Row(
            children: [
              Expanded(
                child: _getPreview(ad.childAds[0]),
              ),
              Expanded(
                child: _getPreview(ad.childAds[1]),
              ),
            ],
          ),
        );
      } else if (ad.childAds.length == 3) {
        return Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 3.0)
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _getPreview(ad.childAds[0]),
                    ),
                    Expanded(
                      child: _getPreview(ad.childAds[2]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _getPreview(ad.childAds[1]),
                    ),
                    Spacer()
                  ],
                ),
              )
            ],
          ),
        );
      } else if (ad.childAds.length == 4) {
        return Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 3.0)
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _getPreview(ad.childAds[0]),
                    ),
                    Expanded(
                      child: _getPreview(ad.childAds[2]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _getPreview(ad.childAds[1]),
                    ),
                    Expanded(
                      child: _getPreview(ad.childAds[3]),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 3.0)
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _getPreview(ad.childAds[0]),
                    ),
                    Expanded(
                      child: _getPreview(ad.childAds[1]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _getPreview(ad.childAds[2]),
                    ),
                    Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _getPreview(ad.childAds[3]),
                            FittedBox(
                              fit: BoxFit.contain,
                              child: new IconTheme(
                                data: new IconThemeData(
                                    color: Colors.black45
                                ),
                                child: new Icon(Icons.more_horiz),
                              ),
                            )
                          ],
                        )
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }
    }
    throw ArgumentError("invalid adType: ${ad.adType}");
  }

  Widget _getThumbnailPreview(String thumbnailPath) {
    return isURL(thumbnailPath)
        ? CachedNetworkImage(
        imageUrl: thumbnailPath,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        )
    )
        : Image.file(File(thumbnailPath), fit: BoxFit.cover);
  }

  String _getThumbnailPath(Ad ad) {
    if (!_isNullOrEmpty(ad.thumbnailPath)) {
      return ad.thumbnailPath;
    } else {
     return ad.mediaPath;
    }
  }

  double _viewWidth(context) => MediaQuery.of(context).size.width / 2 - 10;
  double _viewHeight(context) => MediaQuery.of(context).size.height / 2 - 10;

  bool _isNullOrEmpty(String text) => text == null || text.isEmpty;
}
