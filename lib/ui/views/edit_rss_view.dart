import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:uproplus/core/data/blocs/ad_bloc.dart';
import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/shared/text_styles.dart';
import 'package:uproplus/ui/views/base_view.dart';
import 'package:validators/validators.dart';
import 'package:webfeed/webfeed.dart';

class EditRssView extends StatefulWidget {
  final Ad ad;
  EditRssView({Key key, this.ad}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditRssViewState();
}
class _EditRssViewState extends State<EditRssView> {

  AdBloc _adBloc;
  TextEditingController _adTextController = new TextEditingController();
  String _duration;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    _adBloc = BlocProvider.of<AdBloc>(context);
    _adTextController.text = widget.ad.text == null ? '' : widget.ad.text;
    print("ad duration: ${widget.ad.duration}");
    _duration = _formatDuration(Duration(seconds: widget.ad.duration));

    if (_adTextController.text.isEmpty) {
      _adTextController.text = 'https://www.feedforall.com/sample.xml';
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _showRssInputUrlDialog(context);
      });
    }
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
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  widget.ad.text,
                                  textAlign: TextAlign.left,
                                  style: adTextStyle,
                                ),
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
              label: 'RSSを変更',
              labelStyle: speedDialStyle,
              labelBackgroundColor: speedDialLabelBackgroundColor,
              backgroundColor: goldColor,
              onTap: () { _showRssInputUrlDialog(context); }
          ),
        ],
      ),
    );
  }

  Future _showRssInputUrlDialog(context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Container(
              child: GestureDetector(
                  onTap: () { FocusScope.of(context).requestFocus(FocusNode()); },
                  child: AlertDialog(
                    title: Text('RSS urlを入力'),
                    content: TextField(
                      controller: _adTextController,
                      decoration: InputDecoration(hintText: "http://sample.com/rssfeed.xml"),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: _isNullOrEmpty(widget.ad.text)
                            ? null
                            : () { Navigator.of(context).pop(); },
                        child: Text('キャンセル'),
                        textColor: dialogButtonColor,
                        disabledTextColor: dialogButtonDisabledColor,
                      ),
                      FlatButton(
                        onPressed: _adTextController.text.isEmpty ? null : () async {
                          Navigator.of(context).pop();
                          try {
                            var rssFeed = await _fetchRss(_adTextController.text);
                            widget.ad.text = "${rssFeed.title}\n${rssFeed.description}";
                            widget.ad.mediaPath = rssFeed.image != null
                                ? rssFeed.image.url
                                : '';
                            setState(() {});
                          } catch (error) {
                            _showErrorDialog(context);
                          }
                        },
                        textColor: dialogButtonColor,
                        disabledTextColor: dialogButtonDisabledColor,
                        child: Text('設定'),
                      )
                    ],
                  )
              )
          );
        });
  }

  Future _showErrorDialog(context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('エラー'),
            content: Text('RSSの取得に失敗しました。'),
            actions: <Widget>[
              FlatButton(
                onPressed: () { Navigator.of(context).pop(); },
                child: Text(
                    'OK',
                    style: TextStyle(
                      color: dialogButtonColor,
                    )
                ),
              ),
            ],
          );
        });
  }

  Future<RssFeed> _fetchRss(String url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return RssFeed.parse(response.body);
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  Future _saveAd(context) async {
    setState(() {_isUpdating = true;});
    final ad = widget.ad;

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

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';

  String _formatDuration(Duration duration) {
    print("formatDuration inHours: ${duration.inHours} inMinutes: ${duration.inMinutes} inSeconds: ${duration.inSeconds}");
    return '${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  double _viewHeight(context) => MediaQuery.of(context).size.height;

  bool _isNullOrEmpty(String text) => text == null || text.isEmpty;
}
