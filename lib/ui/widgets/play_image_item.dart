import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/shared/app_colors.dart' as prefix0;
import 'package:uproplus/ui/shared/text_styles.dart';
import 'package:uproplus/ui/views/base_view.dart';
import 'package:validators/validators.dart';

class PlayImageItem extends StatefulWidget {
  final Ad ad;
  final int position;
  final Function onFinished;
  final Stream<int> cancelStream;

  PlayImageItem({this.ad, this.position, this.onFinished, this.cancelStream});

  @override
  _PlayImageItemState createState() => _PlayImageItemState();
}

class _PlayImageItemState extends State<PlayImageItem> {
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
    print(
        "PlayImageItem _maybeCancel widgetPosition: ${widget.position} position: $position");
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
  didUpdateWidget(PlayImageItem old) {
    super.didUpdateWidget(old);
    print(
        "PlayImageItem didUpdateWidget  widgetPosition: ${widget.position} streamEquals:${widget.cancelStream == old.cancelStream}");
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      backgroundColor: backgroundColor,
      body: Container(
        color: prefix0.adMediaBackgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
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
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ))
                          : Image.file(File(widget.ad.mediaPath),
                              fit: BoxFit.contain),
                    ),
                  ),
                  _isNullOrEmpty(widget.ad.text)
                      ? Container()
                      : Expanded(
                          child: Container(
                            height: _viewHeight(context),
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(10),
                            decoration:
                                BoxDecoration(color: Colors.white, boxShadow: [
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
