import 'dart:async';

import 'package:uproplus/core/data/preferences.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/core/data/database.dart';
import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/services/user_service.dart';
import 'package:uproplus/locator.dart';

class AdsBloc implements BlocBase {
  // Create a broadcast controller that allows this stream to be listened
  // to multiple times. This is the primary, if not only, type of stream you'll be using.
  final _adsController = StreamController<List<Ad>>.broadcast();

  final _saveAdController = StreamController<List<Ad>>.broadcast();
  StreamSink<List<Ad>> get inSaveAd => _saveAdController.sink;

  // This bool StreamController will be used to ensure we don't do anything
  // else until an ad is actually saved from the database.
  final _adSavedController = StreamController<bool>.broadcast();
  StreamSink<bool> get _inSavedAd => _adSavedController.sink;
  Stream<bool> get savedAd => _adSavedController.stream;

  // Input stream. We add our ads to the stream using this variable.
  StreamSink<List<Ad>> get _inAds => _adsController.sink;

  // Output stream. This one will be used within our pages to display the ads.
  Stream<List<Ad>> get ads => _adsController.stream;

  // Input stream for adding news. We'll call this from our pages.
  final _fetchNewsController = StreamController<String>.broadcast();
  StreamSink<String> get _inFetchNews => _fetchNewsController.sink;
  Stream<String> get news => _fetchNewsController.stream;

  final _saveNewsController = StreamController<String>.broadcast();
  StreamSink<String> get inSaveNews => _saveNewsController.sink;

  final _newsSavedController = StreamController<bool>.broadcast();
  StreamSink<bool> get _inSavedNews => _newsSavedController.sink;
  Stream<bool> get savedNews => _newsSavedController.stream;

  final UserService _userService = locator<UserService>();

  AdsBloc() {
    _saveAdController.stream.listen(_handleSaveAd);
    _saveNewsController.stream.listen(_handleSaveNews);
  }

  init() {
    // Retrieve all the ads on initialization
    getAds();
    fetchNews();
  }

  // All stream controllers you create should be closed within this function
  @override
  void dispose() {
    _adsController.close();
    _saveAdController.close();
    _adSavedController.close();

    _fetchNewsController.close();
    _saveNewsController.close();
    _newsSavedController.close();
  }

  getAds() async {
    print("getAds");
    try {
      final messageAds = await _userService.downloadAds();
      List<String> idList = [];
      for (var i = 0; i < messageAds.length; i++) {
        final rawAd = messageAds[i];
        final ad = Ad(
            owner: rawAd['user_name'],
            adType: AdType.toType(rawAd['ad']['ad_type']),
            mediaPath: _textOrEmpty(rawAd['ad']['media_path']),
            thumbnailPath: _textOrEmpty(rawAd['ad']['thumbnail_path']),
            duration: rawAd['ad']['ad_duration'],
            text: _textOrEmpty(rawAd['ad']['ad_text']),
            order: rawAd['ad']['ad_order']
        );
        ad.id = rawAd['ad_id'];
        idList.add(ad.id);
        await DbProvider.get().newAd(ad);
        final childIds = rawAd['ad']['child_ids'];
        print(rawAd['ad']['ad_type']);
        print(rawAd['ad']['child_ids']);
        for (var childId in childIds) {
          await DbProvider.get().linkParentChildAd(ad.id, childId);
        }
      }
      await DbProvider.get().deleteOthers(idList);
      // Retrieve all the ads from the database
      List<Ad> ads = await DbProvider.get().getAds();

      // Add all of the ads to the stream so we can grab them later from our pages
      _inAds.add(ads);
    } catch (e) {
      _inAds.addError(e);
    }
  }

  Future<int> getAdCount() async {
    return await DbProvider.get().getAdCount();
  }

  bool isUserAdmin() {
    return _userService.isUserAdmin();
  }

  bool isAdmin(String user) {
    return _userService.isAdmin(user);
  }

  bool isUser(String user) {
    return _userService.isUser(user);
  }

  void _handleSaveAd(List<Ad> ads) async {
    for (var ad in ads) {
      await _saveAd(ad);
    }

    await getAds();
    _inSavedAd.add(true);
  }

  Future _saveAd(Ad ad) async {
    ad = await _userService.uploadAd(ad);
    await DbProvider.get().updateAd(ad);

    if (ad.childAds != null) {
      for(int i = 0; i< ad.childAds.length; i++) {
        final childAd = ad.childAds[i];
        if (childAd.id == null) {
          await _addChildAd(ad.id, childAd);
        } else {
          await _saveChildAd(ad.id, childAd);
        }
      }
    }
  }

  Future _addChildAd(String parentId, Ad ad) async {
    ad.id = await DbProvider.get().newChildAd(parentId, ad);
    ad = await _userService.uploadAd(ad);
    await DbProvider.get().updateAd(ad);
  }

  Future _saveChildAd(String parentId, Ad ad) async {
    var updatedAd = await _userService.uploadAd(ad);
    await DbProvider.get().updateAd(updatedAd);
  }

  fetchNews() async {
    try {
      String news = await _userService.getNews();
      await PreferencesProvider.get().saveNews(news);
      _inFetchNews.add(news);
    } catch (e) {
      _inAds.addError(e);
    }
  }

  void _handleSaveNews(String news) async {
    await _userService.saveNews(news);
    await PreferencesProvider.get().saveNews(news);

    await fetchNews();
    _inSavedNews.add(true);
  }

  String _textOrEmpty(String text) {
    if (text?.isEmpty ?? true) {
      return "";
    } else {
      return text;
    }
  }
}
