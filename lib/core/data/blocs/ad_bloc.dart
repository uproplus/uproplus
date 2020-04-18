import 'dart:async';

import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/core/data/database.dart';
import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/services/user_service.dart';
import 'package:uproplus/locator.dart';
import 'package:uuid/uuid.dart';

class AdBloc implements BlocBase {
  // Input stream for adding new ads. We'll call this from our pages.
  final _addAdController = StreamController<Ad>.broadcast();
  StreamSink<Ad> get inAddAd => _addAdController.sink;

  final _saveAdController = StreamController<Ad>.broadcast();
  StreamSink<Ad> get inSaveAd => _saveAdController.sink;

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

  AdBloc() {
    // Listen for changes to the stream, and execute a function when a change is made
    _addAdController.stream.listen(_handleAddAd);
    _saveAdController.stream.listen(_handleSaveAd);
    _deleteAdController.stream.listen(_handleDeleteAd);
  }

  @override
  void dispose() {
    _addAdController.close();
    _saveAdController.close();
    _adSavedController.close();
    _deleteAdController.close();
    _adDeletedController.close();
  }

  void _handleAddAd(Ad ad) async {
    ad.id = _idGenerator.v1();

    if (ad.childAds != null) {
      for (int i = 0; i< ad.childAds.length; i++) {
        await _handleAddChildAd(ad.id, ad.childAds[i]);
      }
    }

    ad = await _userService.uploadAd(ad);
    await DbProvider.get().newAd(ad);

    _inSaved.add(true);
  }

  Future _handleAddChildAd(String parentId, Ad ad) async {
    ad.id = _idGenerator.v1();
    ad = await _userService.uploadAd(ad);
    await DbProvider.get().newChildAd(parentId, ad);
  }

  void _handleSaveAd(Ad ad) async {
    var updatedAd = await _userService.uploadAd(ad);
    await DbProvider.get().updateAd(updatedAd);

    if (ad.childAds != null) {
      for(int i = 0; i< ad.childAds.length; i++) {
        final childAd = ad.childAds[i];
        if (childAd.id == null) {
          await _handleAddChildAd(ad.id, childAd);
        } else {
          await _handleSaveChildAd(ad.id, childAd);
        }
      }
    }

    _inSaved.add(true);
  }

  Future _handleSaveChildAd(String parentId, Ad ad) async {
    var updatedAd = await _userService.uploadAd(ad);
    await DbProvider.get().updateAd(updatedAd);
  }

  void _handleDeleteAd(Ad ad) async {
    await _userService.deleteAd(ad);
    await DbProvider.get().deleteAd(ad.id);

    _inDeleted.add(true);
  }
}
