import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/shared/text_styles.dart';
import 'package:uproplus/ui/views/base_view.dart';
import 'package:validators/validators.dart';
import 'package:video_player/video_player.dart';

class PlayVideoItem extends StatefulWidget {
  final Ad ad;
  final int position;
  final Function onFinished;
  final Stream<int> cancelStream;

  PlayVideoItem({this.ad, this.position, this.onFinished, this.cancelStream});

  @override
  _PlayVideoItemState createState() => _PlayVideoItemState();
}

class _PlayVideoItemState extends State<PlayVideoItem> {

  DefaultCacheManager _cacheManager = DefaultCacheManager();
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  Function _listener;
  Timer _timer;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    print("PlayVideoItem initState widgetPosition: ${widget.position}");
    _getVideoFile().then((videoFile) {
      _controller = VideoPlayerController.file(videoFile);
      _listener = () {
        if (_controller.value.initialized) {
          if (!_controller.value.isPlaying) {
            _controller.play();
          } else {
            if (_controller.value.position.inMilliseconds == 0) {
              _timer = Timer(_controller.value.duration, () {
                print("PlayVideoItem onFinished widgetPosition: ${widget.position}");
                widget.onFinished();
              });
            }
          }
        }
      };
      _controller.addListener(_listener);
      _initializeVideoPlayerFuture = _controller.initialize();
      if (!_isListening) {
        setState(() {
          _isListening = true;
          widget.cancelStream.listen((int position) => _maybeCancel(position));
        });
      }
    });
  }

  Future<File> _getVideoFile() async {
    return  isURL(widget.ad.mediaPath)
        ? await _cacheManager.getSingleFile(widget.ad.mediaPath)
        : File(widget.ad.mediaPath);
  }

  _maybeCancel(position) {
    print("PlayVideoItem _maybeCancel widgetPosition: ${widget.position} position: $position");
    if (widget.position == position) {
      _timer.cancel();
    }
  }

  @override
  didUpdateWidget(PlayVideoItem old) {
    super.didUpdateWidget(old);
    print("PlayVideoItem didUpdateWidget  widgetPosition: ${widget.position} streamEquals:${widget.cancelStream == old.cancelStream}");
  }

  @override
  void dispose() {
    print("PlayVideoItem disposed widgetPosition: ${widget.position}");
    _controller.dispose();
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      backgroundColor: backgroundColor,
      body: Container(
        color: adMediaBackgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
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
                    child: FutureBuilder(
                      future: _initializeVideoPlayerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          // If the VideoPlayerController has finished initialization, use
                          // the data it provides to limit the aspect ratio of the VideoPlayer.
                          return AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            // Use the VideoPlayer widget to display the video.
                            child: VideoPlayer(_controller),
                          );
                        } else {
                          // If the VideoPlayerController is still initializing, show a
                          // loading spinner.
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                ),
                _isNullOrEmpty(widget.ad.text) ? Container() :
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
            )
          ],
        ),
      ),
    );
  }

  double _viewHeight(context) => MediaQuery.of(context).size.height;

  bool _isNullOrEmpty(String text) => text == null || text.isEmpty;
}
