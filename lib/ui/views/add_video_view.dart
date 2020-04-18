import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/shared/text_styles.dart';
import 'package:uproplus/ui/shared/utils.dart';
import 'package:uproplus/ui/views/base_view.dart';
import 'package:validators/validators.dart';
import 'package:video_player/video_player.dart';

class AddVideoView extends StatefulWidget {
  final Ad ad;
  AddVideoView({Key key, this.ad}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddVideoViewState();
}
class _AddVideoViewState extends State<AddVideoView> {

  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  TextEditingController _adTextController = new TextEditingController();

  @override
  void initState() {
    _controller = isURL(widget.ad.mediaPath)
        ? VideoPlayerController.network(widget.ad.mediaPath)
        : VideoPlayerController.file(File(widget.ad.mediaPath));
    _initializeVideoPlayerFuture = _controller.initialize();

    super.initState();

    _adTextController.text = widget.ad.text;
  }

  @override
  void dispose() {
    _controller.dispose();

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
                Expanded(
                  child: Container(
                    height: _viewHeight(context),
                    alignment: Alignment(0.0, 0.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 3.0,
                              offset: Offset(0.0, 2.0),
                              color: Color.fromARGB(80, 0, 0, 0))
                        ]),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'テキストを入力',
                        hintStyle: adTextHintStyle,
                        contentPadding: const EdgeInsets.all(20.0),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      controller: _adTextController,
                      textAlign: TextAlign.left,
                      textAlignVertical: TextAlignVertical.center,
                      style: adTextStyle,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      maxLengthEnforced: true,
                      maxLength: 100,
                    ),
                  ),
                )
              ],
            )
          ],
        )
      ),
      floatingActionButton: SpeedDial(
        heroTag: 'ad-video-view-menu-hero-tag',
        tooltip: 'Menu',
        backgroundColor: goldColor,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 40.0),
        marginBottom: 20,
        marginRight: 20,
        children: [
          SpeedDialChild(
              child: Icon(Icons.delete, size: 36),
              label: '削除',
              labelStyle: speedDialStyle,
              labelBackgroundColor: speedDialLabelBackgroundColor,
              backgroundColor: goldColor,
              onTap: _deleteAd
          ),
          SpeedDialChild(
              child: Icon(Icons.add, size: 36),
              label: '追加',
              labelStyle: speedDialStyle,
              labelBackgroundColor: speedDialLabelBackgroundColor,
              backgroundColor: goldColor,
              onTap: _saveAd
          ),
          SpeedDialChild(
              child: Icon(_controller.value.isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline, size: 36),
              label: '再生',
              labelStyle: speedDialStyle,
              labelBackgroundColor: speedDialLabelBackgroundColor,
              backgroundColor: goldColor,
              onTap: _playVideo
          ),
          SpeedDialChild(
              child: Icon(Icons.video_library, size: 36),
              label: '動画を変更',
              labelStyle: speedDialStyle,
              labelBackgroundColor: speedDialLabelBackgroundColor,
              backgroundColor: goldColor,
              onTap: _changeVideo
          ),
        ],
      ),
    );
  }

  Future _playVideo() async {
    setState(() {
      // If the video is playing, pause it.
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        // If the video is paused, play it.
        _controller.play();
      }
    });
  }

  Future _changeVideo() async {
    final videoFile = await ImagePicker.pickVideo(source: ImageSource.gallery);
    if (!await Utils.isFileSizeOk(videoFile)) {
      Utils.showMessage(context, 'この大きさを超えるサイズのファイルは使えません。', null, Duration(seconds: 15));
      return;
    }
    final thumbnailPath = await FlutterVideoCompress().getThumbnailWithFile(videoFile.path);
    setState(() {
      final ad = widget.ad;
      ad.mediaPath = videoFile.path;
      ad.thumbnailPath = thumbnailPath.path;

      _controller.dispose();
      _controller = VideoPlayerController.file(videoFile);
      _initializeVideoPlayerFuture = _controller.initialize();
    });
  }

  Future _saveAd() async {
    widget.ad.text = _adTextController.text.trim();
    Navigator.of(context).pop(widget.ad);
  }

  Future _deleteAd() async {
    Navigator.of(context).pop(null);
  }

  double _viewHeight(context) => MediaQuery.of(context).size.height;
}
