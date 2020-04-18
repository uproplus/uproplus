import 'dart:async';

import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/data/preferences.dart';
import 'package:uproplus/core/models/account.dart';
import 'package:uproplus/core/services/user_service.dart';
import 'package:uproplus/locator.dart';

class HomeBloc implements BlocBase {

  // Input stream for adding new ads. We'll call this from our pages.
  final _fetchAccountController = StreamController<Account>.broadcast();
  StreamSink<Account> get inFetchAccount => _fetchAccountController.sink;
  Stream<Account> get fetched => _fetchAccountController.stream;

  final _loggedOutController = StreamController<bool>.broadcast();
  StreamSink<bool> get _inLoggedOut => _loggedOutController.sink;
  Stream<bool> get loggedOut => _loggedOutController.stream;

  HomeBloc();

  @override
  void dispose() {
    _fetchAccountController.close();
    _loggedOutController.close();
  }

  fetchAccount() async {
    Account account = await PreferencesProvider.get().getAccount();
    inFetchAccount.add(account);
  }

  logout() async {
    await locator<UserService>().logout();

    _inLoggedOut.add(true);
  }
}
