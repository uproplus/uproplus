import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';
import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/data/blocs/multi_ad_bloc.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/shared/text_styles.dart';
import 'package:uproplus/ui/views/base_view.dart';
import 'package:uproplus/ui/widgets/add_item.dart';
import 'package:uproplus/ui/widgets/adlist_item.dart';
import 'package:uproplus/ui/widgets/media_type_selection_dialog.dart';

class EditMultiView extends StatefulWidget {
  final Ad ad;
  EditMultiView({Key key, this.ad}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditMultiViewState();
}
class _EditMultiViewState extends State<EditMultiView> {
  final List<AdType> adTypes = [AdType.imageAd, AdType.videoAd, AdType.rssAd];
  MultiAdBloc _multiAdBloc;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    _multiAdBloc = BlocProvider.of<MultiAdBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      body: Stack(
        children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  // The StreamBuilder allows us to make use of our streams and display
                  // that data on our page. It automatically updates when the stream updates.
                  // Whenever you want to display stream data, you'll use the StreamBuilder.
                  child: ReorderableWrap(
                    scrollDirection: Axis.horizontal,
                    direction: Axis.vertical,
                    children: List.generate(widget.ad.childAds.length + 1, (int index) {
                      if (index == widget.ad.childAds.length) {
                        return AddItem(onTap: () => _selectMediaType(context));
                      } else {
                        final Ad ad = widget.ad.childAds[index];
                        ad.order = index;
                        return AdListItem(ad: ad, onTap: () => _addAd(context, ad));
                      }
                    }),
                    onReorder: (int oldIndex, int newIndex) {
                      if (oldIndex >= widget.ad.childAds.length || newIndex >= widget.ad.childAds.length) {
                        return;
                      }
                      print("onReorder oldIndex:$oldIndex newIndex:$newIndex");
                      _reorder(widget.ad.childAds, oldIndex, newIndex);
                    },
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
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 40.0),
        backgroundColor: goldColor,
        children: _getActionWidgets(context),
        visible: !_isUpdating,
      ),
    );
  }

  List<SpeedDialChild> _getActionWidgets(BuildContext context) {
    List<SpeedDialChild> actionWidgets = [];
    bool isEditMode = widget.ad.id != null;
    if (isEditMode) {
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
    }

    actionWidgets.add(
        SpeedDialChild(
            child: Icon(Icons.delete, size: 36),
            label: '削除',
            labelStyle: speedDialStyle,
            labelBackgroundColor: speedDialLabelBackgroundColor,
            backgroundColor: goldColor,
            onTap: () => _deleteAd(context)
        )
    );

    if (widget.ad.childAds.isNotEmpty) {
      actionWidgets.add(
          SpeedDialChild(
              child: Icon(Icons.save, size: 36),
              label: '保存',
              labelStyle: speedDialStyle,
              labelBackgroundColor: speedDialLabelBackgroundColor,
              backgroundColor: goldColor,
              onTap: () => _saveAd(context)
          )
      );
    }

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

  Future _reorder(List<Ad> ads, int oldIndex, int newIndex) async {
    Ad row = ads.removeAt(oldIndex);
    ads.insert(newIndex, row);

    List<Ad> reorderedAds = [];

    final fromIndex = min(oldIndex, newIndex);
    final toIndex = max(oldIndex, newIndex);
    for (int index = fromIndex; index <= toIndex; index++) {
      ads[index].order = index;
      reorderedAds.add(ads[index]);
    }

    if (widget.ad.id != null) {
      _multiAdBloc.inSaveAd.add(reorderedAds);

      _multiAdBloc.saved.listen((saved) {
        if (saved) {
          setState(() {});
        }
      });
    } else {
      setState(() {});
    }
  }

  Future _addAd(BuildContext context, Ad ad) async {
    var routeName;
    if (ad.adType == AdType.imageAd) {
      routeName = 'add_ad_image';
    } else if (ad.adType == AdType.videoAd) {
      routeName = 'add_ad_video';
    } else  {
      routeName = 'add_ad_rss';
    }
    print("edit routeName: $routeName ad: $ad context: $context");
    var returnedAd = await Navigator.of(context).pushNamed(routeName, arguments: ad);
    print("returnedAd: $returnedAd");
    if (returnedAd is Ad) {
      final index = returnedAd.order;
      print("returnedAd index: $index childAdsLength: ${widget.ad.childAds.length}");
      if (returnedAd.id != null || index < widget.ad.childAds.length) {
        widget.ad.childAds.removeAt(index);
        widget.ad.childAds.insert(index, returnedAd);

        _multiAdBloc.inSaveAd.add([returnedAd]);

        _multiAdBloc.saved.listen((saved) {
          if (saved) {
            setState(() {});
          }
        });
      } else {
        setState(() {
          widget.ad.childAds.add(returnedAd);
        });
      }
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
              }
              else {
                _addRssFeed(context);
              }
            },
          );
        }
    );
  }

  Future _saveAd(context) async {
    if (widget.ad.childAds.isEmpty) {
      return;
    }
    setState(() {_isUpdating = true;});

    final isNewAd = widget.ad.id == null;

    _multiAdBloc.inSaveAd.add([widget.ad]);

    _multiAdBloc.saved.listen((saved) async {
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
    bool isEditMode = widget.ad.id != null;
    if (!isEditMode) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {_isUpdating = true;});
    final ad = widget.ad;
    _multiAdBloc.inDeleteAd.add(ad);

    _multiAdBloc.deleted.listen((deleted) async {
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

  Future _addLocalImage(BuildContext context) async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) {
      return;
    }
    final ad = Ad(
        adType: AdType.imageAd,
        mediaPath: imageFile.path,
        duration: 10,
        order: widget.ad.childAds.length
    );
    await _addAd(context, ad);
  }

  Future _addLocalVideo(BuildContext context) async {
    final videoFile = await ImagePicker.pickVideo(source: ImageSource.gallery);
    if (videoFile == null) {
      return;
    }
    final thumbnailPath = await FlutterVideoCompress().getThumbnailWithFile(videoFile.path);
    final ad = Ad(
        adType: AdType.videoAd,
        mediaPath: videoFile.path,
        thumbnailPath: thumbnailPath.path,
        duration: 10,
        order: widget.ad.childAds.length
    );
    await _addAd(context, ad);
  }

  Future _addRssFeed(BuildContext context) async {
    final ad = Ad(
        adType: AdType.rssAd,
        text: '',
        duration: 10,
        order: widget.ad.childAds.length
    );
    await _addAd(context, ad);
  }
}
