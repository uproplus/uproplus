import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uproplus/core/data/blocs/ad_bloc.dart';
import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/shared/text_styles.dart';
import 'package:uproplus/ui/shared/utils.dart';
import 'package:uproplus/ui/views/base_view.dart';
import 'package:validators/validators.dart';

class EditImageView extends StatefulWidget {
  final Ad ad;
  EditImageView({Key key, this.ad}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditImageViewState();
}
class _EditImageViewState extends State<EditImageView> {

  AdBloc _adBloc;
  TextEditingController _adTextController = new TextEditingController();
  String _duration;
  bool _isUpdating = false;
//  final _mediaTypes = [101, 102];
//  final TextEditingController _remoteUrlController = TextEditingController();
//  int _selectedMediaType;

  @override
  void initState() {
    super.initState();

    _adBloc = BlocProvider.of<AdBloc>(context);
    _adTextController.text = widget.ad.text;
    print("ad mediaPath: ${widget.ad.mediaPath} isURL: ${isURL(widget.ad.mediaPath)}");
    _duration = _formatDuration(Duration(seconds: widget.ad.duration));
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
                Expanded(
                  child: Row(
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
                          alignment: Alignment(0.0, 0.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 3.0,
                                    offset: Offset(0.0, 2.0),
                                    color: Color.fromARGB(80, 0, 0, 0))
                              ]),
                          child: Stack(
                            alignment: Alignment(0.0, 0.0),
                            fit: StackFit.loose,
                            children: [
                              TextField(
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
                              Positioned(
                                child: Container(
                                    margin: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 90.0),
                                    child: Column(
                                      children: [
                                        Spacer(),
                                        RaisedButton(
                                          onPressed: () {
                                            var duration = Duration(seconds: widget.ad.duration);
                                            var time = DateTime(0,0,0,duration.inHours.remainder(60),duration.inMinutes.remainder(60),duration.inSeconds.remainder(60),0,0);
                                            DatePicker.showTimePicker(context,
                                                theme: DatePickerTheme(
                                                  containerHeight: 210.0,
                                                ),
                                                showTitleActions: true, onConfirm: (time) {
                                                  setState(() {
                                                    widget.ad.duration = time.minute * 60 + time.second;
                                                    _duration = _formatTime(time);
                                                  });
                                                }, currentTime: time, locale: LocaleType.en);
                                            setState(() {});
                                          },
                                          color: goldColor,
                                          child: Container(
                                            height: 60.0,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.timer,
                                                  color: Colors.white70,
                                                ),
                                                Text(
                                                  "$_duration",
                                                  style: TextStyle(fontSize: 26, color: Colors.white70),
                                                ),
                                                Spacer(),
                                                Text(
                                                  '時間変更',
                                                  style: TextStyle(fontSize: 26, color: Colors.white),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
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
        heroTag: 'ad-media-view-menu-hero-tag',
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
              child: Icon(Icons.image, size: 36),
              label: '画像を変更',
              labelStyle: speedDialStyle,
              labelBackgroundColor: speedDialLabelBackgroundColor,
              backgroundColor: goldColor,
              onTap: () => _changeImage()
          ),
        ],
      ),
    );
  }

  Future _changeImage() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (!await Utils.isFileSizeOk(imageFile)) {
      Utils.showMessage(context, 'この大きさを超えるサイズのファイルは使えません。', null, Duration(seconds: 15));
      return;
    }
    final ad = widget.ad;
    ad.mediaPath = imageFile.path;
  }

//  Future _changeImageUrl(String url) async {
//    final ad = widget.ad;
//    ad.mediaPath = url;
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
//        builder: (BuildContext context) {
//          return AlertDialog(
//            title: Text("Select Media Type"),
//            content: SingleChildScrollView(
//              child: MediaTypeRadioGroup(_mediaTypes, _setSelectedMediaType),
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
//      case 101:
//        await _changeImage();
//        break;
//      case 102:
//        _inputRemoteMediaUrl(context);
//        break;
//        break;
//    }
//  }
//
//  void _inputRemoteMediaUrl(context) {
//    showDialog(
//        context: context,
//        builder: (BuildContext context) {
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
//                  _changeImageUrl(_remoteUrlController.text);
//                },
//              ),
//            ],
//          );
//        }
//    );
//  }

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';

  String _formatDuration(Duration duration) {
    print("formatDuration inHours: ${duration.inHours} inMinutes: ${duration.inMinutes} inSeconds: ${duration.inSeconds}");
    return '${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  double _viewHeight(context) => MediaQuery.of(context).size.height;
}
