import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uproplus/core/data/blocs/ad_bloc.dart';
import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/shared/text_styles.dart';
import 'package:uproplus/ui/shared/utils.dart';
import 'package:uproplus/ui/views/base_view.dart';
import 'package:validators/validators.dart';
import 'package:video_player/video_player.dart';

class EditVideoView extends StatefulWidget {
  final Ad ad;
  EditVideoView({Key key, this.ad}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditVideoViewState();
}
class _EditVideoViewState extends State<EditVideoView> {

  TextEditingController _adTextController = new TextEditingController();
  AdBloc _adBloc;
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  bool _isUpdating = false;
//  final mediaTypes = [201, 202];
//  int _selectedMediaType;
//  final TextEditingController _remoteUrlController = TextEditingController();

  @override
  void initState() {
    _controller = isURL(widget.ad.mediaPath)
        ? VideoPlayerController.network(widget.ad.mediaPath)
        : VideoPlayerController.file(File(widget.ad.mediaPath));
    _initializeVideoPlayerFuture = _controller.initialize();

    super.initState();

    _adBloc = BlocProvider.of<AdBloc>(context);
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
      body: Stack(
        children: [
          Container(
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
            ),
          ),
          _isUpdating ?
          Stack(
            children: [
              Opacity(
                opacity: 0.3,
                child: const ModalBarrier(dismissible: false, color: Colors.grey),
              ),
              Center(
                child: new CircularProgressIndicator(),
              ),
            ],
          ) :
          Container()
        ],
      ),
      floatingActionButton: SpeedDial(
        heroTag: 'ad-video-view-menu-hero-tag',
        tooltip: 'Menu',
        backgroundColor: goldColor,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 40.0),
        marginBottom: 20,
        marginRight: 20,
        visible: !_isUpdating,
        children: [
          SpeedDialChild(
              child: Icon(Icons.transit_enterexit, size: 36),
              label: '戻る',
              labelStyle: speedDialStyle,
              labelBackgroundColor: speedDialLabelBackgroundColor,
              backgroundColor: goldColor,
              onTap: () { Navigator.of(context).pop(true); }
          ),
          SpeedDialChild(
              child: Icon(Icons.delete, size: 36),
              label: '削除',
              labelStyle: speedDialStyle,
              labelBackgroundColor: speedDialLabelBackgroundColor,
              backgroundColor: goldColor,
              onTap: () => _deleteAd(context)
          ),
          SpeedDialChild(
              child: Icon(Icons.save, size: 36),
              label: '保存',
              labelStyle: speedDialStyle,
              labelBackgroundColor: speedDialLabelBackgroundColor,
              backgroundColor: goldColor,
              onTap: () => _saveAd(context)
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
              onTap: () { _changeVideo(); }
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

//  Future _changeVideoUrl(String url) async {
//    setState(() {
//      final ad = widget.ad;
//      ad.mediaPath = url;
//
//      _controller.dispose();
//      _controller = VideoPlayerController.network(url);
//      _initializeVideoPlayerFuture = _controller.initialize();
//    });
//  }

  Future _saveAd(context) async {
    setState(() {_isUpdating = true;});
    final ad = widget.ad;
    ad.text = _adTextController.text.trim();

    final isNewAd = ad.id == null;
    if (isNewAd) {
      _adBloc.inAddAd.add(ad);
    } else {
      _adBloc.inSaveAd.add(ad);
    }

    _adBloc.saved.listen((saved) async {
      if (saved) {
        await _promptUpdated(
            context,
            isNewAd
                ? '広告スライド追加完了しました'
                : '広告スライド保存しました');
        Navigator.of(context).pop(true);
      }
    });
  }

  Future _deleteAd(context) async {
    setState(() {_isUpdating = true;});
    final ad = widget.ad;
    _adBloc.inDeleteAd.add(ad);

    _adBloc.deleted.listen((deleted) async {
      if (deleted) {
        await _promptUpdated(context, '広告スライド削除しました');
        Navigator.of(context).pop(true);
      }
    });
  }

  Future _promptUpdated(context, String message) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        }
    );
  }

//  void _selectNewAdType(context) {
//    setState(() {
//      _selectedMediaType = 0;
//      _remoteUrlController.text = "";
//    });
//
//    showDialog(
//        context: context,
//        builder: (_) {
//          return AlertDialog(
//            title: Text("Select Media Type"),
//            content: SingleChildScrollView(
//              child: MediaTypeRadioGroup(mediaTypes, _setSelectedMediaType),
//            ),
//            actions: <Widget>[
//              FlatButton(
//                child: Text('キャンセル'),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                },
//              ),
//              FlatButton(
//                child: Text('次へ'),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                  _delegateSelectedMedia(context);
//                },
//              ),
//            ],
//          );
//        }
//    );
//  }
//
//  void _setSelectedMediaType(int selected) {
//    _selectedMediaType = selected;
//  }
//
//  Future _delegateSelectedMedia(context) async {
//    switch (_selectedMediaType) {
//      case 201:
//        await _changeVideo();
//        break;
//      case 202:
//        _inputRemoteMediaUrl(context);
//        break;
//    }
//  }
//
//  void _inputRemoteMediaUrl(context) {
//    showDialog(
//        context: context,
//        builder: (_) {
//          return AlertDialog(
//            title: Text("Select Media Type"),
//            content: TextField(
//              decoration: InputDecoration.collapsed(hintText: 'https://'),
//              controller: _remoteUrlController,
//            ),
//            actions: <Widget>[
//              FlatButton(
//                child: Text('キャンセル'),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                },
//              ),
//              FlatButton(
//                child: Text('次へ'),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                  _changeVideoUrl(_remoteUrlController.text);
//                },
//              ),
//            ],
//          );
//        }
//    );
//  }

  double _viewHeight(context) => MediaQuery.of(context).size.height;
}
