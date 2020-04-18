import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/shared/text_styles.dart';
import 'package:uproplus/ui/shared/utils.dart';
import 'package:uproplus/ui/views/base_view.dart';
import 'package:validators/validators.dart';

class AddImageView extends StatefulWidget {
  final Ad ad;
  AddImageView({Key key, this.ad}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddImageViewState();
}
class _AddImageViewState extends State<AddImageView> {

  TextEditingController _adTextController = new TextEditingController();
  String _duration;

  @override
  void initState() {
    super.initState();

    _adTextController.text = widget.ad.text;
    print("ad duration: ${widget.ad.duration}");
    _duration = _formatDuration(Duration(seconds: widget.ad.duration));
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
      floatingActionButton: SpeedDial(
        heroTag: 'ad-media-view-menu-hero-tag',
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
              child: Icon(Icons.image, size: 36),
              label: '画像を変更',
              labelStyle: speedDialStyle,
              labelBackgroundColor: speedDialLabelBackgroundColor,
              backgroundColor: goldColor,
              onTap: () { _changeImage(); }
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

  Future _saveAd() async {
    final ad = widget.ad;
    ad.text = _adTextController.text;
    Navigator.of(context).pop(ad);
  }

  Future _deleteAd() async {
    Navigator.of(context).pop(null);
  }

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';

  String _formatDuration(Duration duration) {
    print("formatDuration inHours: ${duration.inHours} inMinutes: ${duration.inMinutes} inSeconds: ${duration.inSeconds}");
    return '${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  double _viewHeight(context) => MediaQuery.of(context).size.height;
}
