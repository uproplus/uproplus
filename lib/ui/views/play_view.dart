import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
import 'package:uproplus/core/data/blocs/ads_bloc.dart';
import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/core/services/user_service.dart';
import 'package:uproplus/locator.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/views/base_view.dart';
import 'package:uproplus/ui/widgets/autoscroll_text.dart';
import 'package:uproplus/ui/widgets/play_image_item.dart';
import 'package:uproplus/ui/widgets/play_rss_item.dart';
import 'package:uproplus/ui/widgets/play_video_item.dart';

class PlayView extends StatefulWidget {

  PlayView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayViewState();
}
class _PlayViewState extends State<PlayView> {

  final UserService _userService = locator<UserService>();
  AdsBloc _adsBloc;
  final PageController _pageController = PageController();
  final cancelPageNotifier = new StreamController<int>.broadcast();

  @override
  void initState() {
    _adsBloc = BlocProvider.of<AdsBloc>(context);
    super.initState();

    Screen.keepOn(true);
    _adsBloc.init();
  }

  @override
  void dispose() {
    cancelPageNotifier.close();
    Screen.keepOn(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            StreamBuilder<List<Ad>>(
                stream: _adsBloc.ads,
                builder: (BuildContext context, AsyncSnapshot<List<Ad>> snapshot) {
                  // Make sure data exists and is actually loaded
                  if (snapshot.hasData) {
                    int lastPage = 0;
                    List<Ad> ads = snapshot.data.map((ad) {
                      if (ad.adType == AdType.multiAd) {
                        return ad.childAds;
                      } else {
                        return [ad];
                      }
                    }).expand((ad) => ad).toList();
                    print("ads length: ${ads.length}");

                    return PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _pageController,
//                physics: NeverScrollableScrollPhysics(),
                      itemCount: ads.length,
                      onPageChanged: (position) {
                        final page = position % ads.length;
                        print("onPageChanged page: $page lastPage: $lastPage");
                        //cancelPageNotifier.sink.add(lastPage);
                        lastPage = page;
                      },
                      itemBuilder: (context, page) {
                        return _buildPage(ads[page], page, () {
                          print("scrollNext page: $page lastPage: $lastPage");
                          if (lastPage == page) {
                            int nextPage = page + 1;
                            if (nextPage >= ads.length) {
                              nextPage = 0;
                            }
                            scrollNext(nextPage);
                          }
                        });
                      },
                    );
                  }

                  if (snapshot.hasError) {
                    print("play_view: ${snapshot.error}");
                    WidgetsBinding.instance.addPostFrameCallback((_) =>
                        _promptExitDialog(context, 'ページを読み込めません。インターネット接続をご確認ください。')
                    );
                    return Container();
                  }

                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _userService.getUser().isAdmin() ?
                Container(
                  height: 60.0,
                  width: 60.0,
                  child: GestureDetector(
                    onLongPress: () {Navigator.pop(context);},
                  ),
                )
                : Container(),
                Spacer(),
                Container(
                  height: 50.0,
                  color: Colors.black12,
                  padding: EdgeInsets.only(left: 2.0, right: 2.0),
                  child: StreamBuilder<String>(
                    stream: _adsBloc.news,
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        var news = snapshot.data;
                        return AutoScrollText(
                            width: _viewWidth(context),
                            text: news
                        );
                      }
                      return Container();
                    },
                  ),
                )
              ],
            )
          ],
        ),
    );
  }

  Widget _buildPage(Ad ad, int position, Function onFinished) {
    if (ad.adType == AdType.imageAd) {
      return PlayImageItem(ad: ad, position: position, onFinished: onFinished, cancelStream: cancelPageNotifier.stream,);
    } else if (ad.adType == AdType.rssAd) {
      return PlayRssItem(ad: ad, position: position, onFinished: onFinished, cancelStream: cancelPageNotifier.stream,);
    } else {
      return PlayVideoItem(ad: ad, position: position, onFinished: onFinished, cancelStream: cancelPageNotifier.stream,);
    }
  }

  scrollNext(int nextPage) {
    _pageController.animateToPage(nextPage, duration: Duration(milliseconds: 500), curve: Curves.ease);
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
