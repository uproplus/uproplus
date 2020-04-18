import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';
import 'package:uproplus/core/data/blocs/ads_bloc.dart';
import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/shared/text_styles.dart';
import 'package:uproplus/ui/shared/utils.dart';
import 'package:uproplus/ui/views/base_view.dart';
import 'package:uproplus/ui/widgets/add_item.dart';
import 'package:uproplus/ui/widgets/adlist_item.dart';
import 'package:uproplus/ui/widgets/autoscroll_text.dart';
import 'package:uproplus/ui/widgets/media_type_selection_dialog.dart';

class EditGridView extends StatefulWidget {

  EditGridView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditGridViewState();
}
class _EditGridViewState extends State<EditGridView> {
  final List<AdType> adTypes = [
    AdType.imageAd,
    AdType.videoAd,
    AdType.rssAd,
    AdType.multiAd
  ];
  AdsBloc _adsBloc;

  TextEditingController _tickerTextController = new TextEditingController();
  bool _isNewsEditable = false;
  final Set<String> _userList = HashSet();
  final Set<String> _selectedUsers = HashSet();

  @override
  void initState() {
    _adsBloc = BlocProvider.of<AdsBloc>(context);
    super.initState();

    _adsBloc.init();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              // The StreamBuilder allows us to make use of our streams and display
              // that data on our page. It automatically updates when the stream updates.
              // Whenever you want to display stream data, you'll use the StreamBuilder.
              child: Stack(
                children: [
                  StreamBuilder<List<Ad>>(
                    stream: _adsBloc.ads,
                    builder: (BuildContext context, AsyncSnapshot<List<Ad>> snapshot) {
                      // Make sure data exists and is actually loaded
                      if (snapshot.hasData) {
                        print("StreamBuilder rebuilding...");
                        print(_userList);

                        if (_userList.isEmpty) {
                          final users = snapshot.data
                              .where((ad) => _adsBloc.isUserAdmin() || _adsBloc.isAdmin(ad.owner) || _adsBloc.isUser(ad.owner))
                              .map((ad) => ad.owner).toList();
                          _userList.addAll(users);
                          _selectedUsers.addAll(users);
                        }
                        print(_userList);
                        print(_selectedUsers);

                        List<AdListItem> adWidgets = [];
                        adWidgets.addAll(
                            snapshot.data
                                .where((ad) => _selectedUsers.contains(ad.owner))
                                .map((ad) => AdListItem(ad: ad, onTap: () => _editAd(context, ad))).toList()
                        );
                        adWidgets.add(AddItem(onTap: () => _selectMediaType(context)));

                        return Stack(
                          children: [
                            ReorderableWrap(
                              scrollDirection: Axis.horizontal,
                              direction: Axis.vertical,
                              children: adWidgets,
                              onReorder: (int oldIndex, int newIndex) {
                                if (oldIndex >= adWidgets.length || newIndex >= adWidgets.length) {
                                  return;
                                }
                                print("onReorder oldIndex:$oldIndex newIndex:$newIndex");
                                _reorder(adWidgets, oldIndex, newIndex);
                              },
                            ),
                            !_adsBloc.isUserAdmin()
                                ? Container()
                                : Column(
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                          height: 50.0,
                                          color: Colors.black38,
                                          margin: EdgeInsets.only(right: 5, top: 5),
                                          child: Theme(
                                              data: Theme.of(context).copyWith(
                                                canvasColor: Colors.black,
                                              ),
                                              child: DropdownButton<String>(
                                                value: _selectedUsers.isEmpty ? null : _selectedUsers.last,
                                                onChanged: (String newValue) {
                                                  setState(() {
                                                    if (_selectedUsers.contains(newValue))
                                                      _selectedUsers.remove(newValue);
                                                    else
                                                      _selectedUsers.add(newValue);
                                                  });
                                                },
                                                items: _userList.map<DropdownMenuItem<String>>((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.check,
                                                            color: _selectedUsers.contains(value) ? Colors.white : Colors.transparent,
                                                          ),
                                                          SizedBox(width: 16),
                                                          Text(
                                                            value,
                                                            style: TextStyle(fontSize: 22, color: Colors.white),
                                                          ),
                                                        ]
                                                    ),
                                                  );
                                                },
                                                ).toList(),
                                                iconEnabledColor: Colors.white,
                                              ),
                                          )
                                      )
                                    ]
                                ),
                                Spacer(),
                              ],
                            ),
                          ]
                        );
                      }

                      if (snapshot.hasError) {
                        print("edit_grid_view: ${snapshot.error}");
                        WidgetsBinding.instance.addPostFrameCallback((_) =>
                            _promptExitDialog(context, 'ページを読み込めません。インターネット接続をご確認ください。')
                        );
                        return Container();
                      }

                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                  Column(
                    children: [
                      Spacer(),
                      Container(
                        height: 50.0,
                        color: Colors.black12,
                        padding: EdgeInsets.only(left: 2.0, right: 2.0),
                        child: StreamBuilder<String>(
                          stream: _adsBloc.news,
                          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                            if (!_isNewsEditable && snapshot.hasData) {
                              _tickerTextController.text = snapshot.data;
                            }
                            return GestureDetector(
                              onTap: () => { _editNewsTicker(context) },
                              child: AutoScrollText(
                                  width: _viewWidth(context),
                                  text: snapshot.hasData ? snapshot.data : ""
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        heroTag: 'ad-media-view-menu-hero-tag',
        tooltip: 'Menu',
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 40.0),
        backgroundColor: goldColor,
        children: _getActionWidgets(context),
      ),
    );
  }

  List<SpeedDialChild> _getActionWidgets(BuildContext context) {
    List<SpeedDialChild> actionWidgets = [];

    actionWidgets.add(
        SpeedDialChild(
            child: Icon(Icons.transit_enterexit, size: 36),
            label: '戻る',
            labelStyle: speedDialStyle,
            labelBackgroundColor: speedDialLabelBackgroundColor,
            backgroundColor: goldColor,
            onTap: () { Navigator.of(context).pop(true); }
        )
    );
    actionWidgets.add(
        SpeedDialChild(
            child: Icon(Icons.add, size: 36),
            label: '追加',
            labelStyle: speedDialStyle,
            labelBackgroundColor: speedDialLabelBackgroundColor,
            backgroundColor: goldColor,
            onTap: () { _selectMediaType(context); }
        )
    );
    return actionWidgets;
  }

  Future _reorder(List<AdListItem> ads, int oldIndex, int newIndex) async {
    AdListItem row = ads.removeAt(oldIndex);
    ads.insert(newIndex, row);

    List<Ad> reorderedAds = [];

    final fromIndex = min(oldIndex, newIndex);
    final toIndex = max(oldIndex, newIndex);
    for (int index = fromIndex; index <= toIndex; index++) {
      ads[index].ad.order = index;
      reorderedAds.add(ads[index].ad);
    }

    _adsBloc.inSaveAd.add(reorderedAds);
    _adsBloc.savedAd.listen((saved) {
      if (saved) {
        setState(() {});
      }
    });
  }

  Future _editAd(BuildContext context, Ad ad) async {
    var routeName;
    if (ad.adType == AdType.imageAd) {
      routeName = 'edit_ad_image';
    } else if (ad.adType == AdType.videoAd) {
      routeName = 'edit_ad_video';
    } else if (ad.adType == AdType.rssAd) {
      routeName = 'edit_ad_rss';
    } else if (ad.adType == AdType.multiAd) {
      routeName = 'edit_ad_multi';
    }
    print("edit routeName: $routeName ad: $ad context: $context");
    var update = await Navigator.of(context).pushNamed(routeName, arguments: ad);
    if (update != null) {
      _adsBloc.getAds();
    }
  }

  void _selectMediaType(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return MediaTypeSelectionDialog(
            adTypes: adTypes,
            onSelected: (AdType selectedAdType) {
              if (selectedAdType == AdType.imageAd) {
                _addLocalImage(context);
              } else if (selectedAdType == AdType.videoAd) {
                _addLocalVideo(context);
              } else if (selectedAdType == AdType.rssAd) {
                _addRssFeed(context);
              } else if (selectedAdType == AdType.multiAd) {
                _addMultiAd(context);
              }
            },
          );
        }
    );
  }

  Future _addLocalImage(BuildContext context) async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) {
      return;
    }
    if (!await Utils.isFileSizeOk(imageFile)) {
      Utils.showMessage(context, 'この大きさを超えるサイズのファイルは使えません。', null, Duration(seconds: 15));
      return;
    }
    final ad = Ad(
        adType: AdType.imageAd,
        mediaPath: imageFile.path,
        duration: 10,
        order: await _adsBloc.getAdCount()
    );
    await _editAd(context, ad);
  }

  Future _addLocalVideo(BuildContext context) async {
    final videoFile = await ImagePicker.pickVideo(source: ImageSource.gallery);
    if (videoFile == null) {
      return;
    }
    if (!await Utils.isFileSizeOk(videoFile)) {
      Utils.showMessage(context, 'この大きさを超えるサイズのファイルは使えません。', null, Duration(seconds: 15));
      return;
    }
    final thumbnailPath = await FlutterVideoCompress().getThumbnailWithFile(videoFile.path);
    final ad = Ad(
        adType: AdType.videoAd,
        mediaPath: videoFile.path,
        thumbnailPath: thumbnailPath.path,
        duration: 10,
        order: await _adsBloc.getAdCount()
    );
    await _editAd(context, ad);
  }

  Future _addRssFeed(BuildContext context) async {
    final ad = Ad(
        adType: AdType.rssAd,
        text: '',
        duration: 10,
        order: await _adsBloc.getAdCount()
    );
    await _editAd(context, ad);
  }

  Future _addMultiAd(BuildContext context) async {
    final ad = Ad(
        adType: AdType.multiAd,
        order: await _adsBloc.getAdCount()
    );
    await _editAd(context, ad);
  }

  void _editNewsTicker(context) {
    setState(() {
      _isNewsEditable = true;
    });
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text("ニュースを更新"),
              content: TextField(
                controller: _tickerTextController,
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(fontSize: 26, color: Colors.black),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    _adsBloc.inSaveNews.add(_tickerTextController.text);
                    _adsBloc.savedNews.listen((saved) {
                      if (saved) {
                        setState(() {
                          _isNewsEditable = false;
                        });
                        Navigator.of(context).pop();
                      }
                    });
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  _promptExitDialog(context, String message) {
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
                    // exit dialog
                    Navigator.of(context).pop();
                    // exit page
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  double _viewWidth(context) => MediaQuery.of(context).size.width;
}
