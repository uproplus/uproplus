import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/shared/text_styles.dart';
import 'package:uproplus/ui/views/base_view.dart';
import 'package:validators/validators.dart';

class PlayRssItem extends StatefulWidget {
  final Ad ad;
  final int position;
  final Function onFinished;
  final Stream<int> cancelStream;

  PlayRssItem({this.ad, this.position, this.onFinished, this.cancelStream});

  @override
  _PlayRssItemState createState() => _PlayRssItemState();
}

class _PlayRssItemState extends State<PlayRssItem> {

  Timer _timer;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    print("PlayImageItem initState widgetPosition: ${widget.position}");
    _timer = Timer(Duration(seconds: widget.ad.duration), () {
      print("PlayImageItem onFinished widgetPosition: ${widget.position}");
      widget.onFinished();
    });
    if (!_isListening) {
      setState(() {
        _isListening = true;
        widget.cancelStream.listen((int position) => _maybeCancel(position));
      });
    }
  }

  _maybeCancel(position) {
    print("PlayImageItem _maybeCancel widgetPosition: ${widget.position} position: $position");
    if (widget.position == position) {
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    print("PlayImageItem disposed widgetPosition: ${widget.position}");
    _timer.cancel();
    super.dispose();
  }

  @override
  didUpdateWidget(PlayRssItem old) {
    super.didUpdateWidget(old);
    print("PlayImageItem didUpdateWidget  widgetPosition: ${widget.position} streamEquals:${widget.cancelStream == old.cancelStream}");
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      backgroundColor: backgroundColor,
      body: Container(
        color: adMediaBackgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              // The StreamBuilder allows us to make use of our streams and display
              // that data on our page. It automatically updates when the stream updates.
              // Whenever you want to display stream data, you'll use the StreamBuilder.
              child: Row(
                children: <Widget>[
                  _isNullOrEmpty(widget.ad.mediaPath) ? Container() :
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: adMediaBackgroundColor,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 3.0,
                                offset: Offset(0.0, 2.0),
                                color: Color.fromARGB(80, 0, 0, 0))
                          ]),
                      child: isURL(widget.ad.mediaPath)
                          ? CachedNetworkImage(
                          imageUrl: widget.ad.mediaPath,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                      )
                          : Image.file(File(widget.ad.mediaPath), fit: BoxFit.cover),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: _viewHeight(context),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 3.0,
                                offset: Offset(0.0, 2.0),
                                color: Color.fromARGB(80, 0, 0, 0))
                          ]),
                      child: Text(
                        widget.ad.text,
                        textAlign: TextAlign.left,
                        style: adTextStyle,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _viewHeight(context) => MediaQuery.of(context).size.height;

  bool _isNullOrEmpty(String text) => text == null || text.isEmpty;
}
