import 'dart:async';

import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/core/data/database.dart';
import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/services/user_service.dart';
import 'package:uproplus/locator.dart';
import 'package:uuid/uuid.dart';

class MultiAdBloc implements BlocBase {
  // Create a broadcast controller that allows this stream to be listened
  // to multiple times. This is the primary, if not only, type of stream you'll be using.
  final _adsController = StreamController<List<Ad>>.broadcast();

  final _saveAdController = StreamController<List<Ad>>.broadcast();
  StreamSink<List<Ad>> get inSaveAd => _saveAdController.sink;

  // This bool StreamController will be used to ensure we don't do anything
  // else until an ad is actually saved from the database.
  final _adSavedController = StreamController<bool>.broadcast();
  StreamSink<bool> get _inSaved => _adSavedController.sink;
  Stream<bool> get saved => _adSavedController.stream;

  final _deleteAdController = StreamController<Ad>.broadcast();
  StreamSink<Ad> get inDeleteAd => _deleteAdController.sink;

  // This bool StreamController will be used to ensure we don't do anything
  // else until an ad is actually deleted from the database.
  final _adDeletedController = StreamController<bool>.broadcast();
  StreamSink<bool> get _inDeleted => _adDeletedController.sink;
  Stream<bool> get deleted => _adDeletedController.stream;

  final UserService _userService = locator<UserService>();

  final Uuid _idGenerator = Uuid();

  MultiAdBloc() {
    _saveAdController.stream.listen(_handleSaveAd);
    _deleteAdController.stream.listen(_handleDeleteAd);
  }

  // All stream controllers you create should be closed within this function
  @override
  void dispose() {
    _adsController.close();
    _saveAdController.close();
    _adSavedController.close();
    _deleteAdController.close();
    _adDeletedController.close();
  }

  void _handleSaveAd(List<Ad> ads) async {
    for (Ad ad in ads) {
      await _saveAd(ad);
    }

    _inSaved.add(true);
  }

  Future _saveAd(Ad ad) async {
    if (ad.id == null) {
      ad.id = _idGenerator.v1();
    }

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

    ad = await _userService.uploadAd(ad);
    await DbProvider.get().newAd(ad);

  }

  Future _addChildAd(String parentId, Ad ad) async {
    ad.id = _idGenerator.v1();
    var updatedAd = await _userService.uploadAd(ad);
    await DbProvider.get().newChildAd(parentId, updatedAd);
  }

  Future _saveChildAd(String parentId, Ad ad) async {
    var updatedAd = await _userService.uploadAd(ad);
    await DbProvider.get().updateAd(updatedAd);
  }

  void _handleDeleteAd(Ad ad) async {
    await _userService.deleteAd(ad);
    await DbProvider.get().deleteAd(ad.id);

    _inDeleted.add(true);
  }
}
