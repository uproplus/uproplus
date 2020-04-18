import 'dart:async';

import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/data/preferences.dart';
import 'package:uproplus/core/models/account.dart';

class LoginBloc implements BlocBase {

  // Input stream for adding new ads. We'll call this from our pages.
  final _fetchAccountController = StreamController<Account>.broadcast();
  StreamSink<Account> get inFetchAccount => _fetchAccountController.sink;
  Stream<Account> get fetched => _fetchAccountController.stream;

  final _saveAccountController = StreamController<Account>.broadcast();
  StreamSink<Account> get inSaveAccount => _saveAccountController.sink;

  final _accountSavedController = StreamController<bool>.broadcast();
  StreamSink<bool> get _inSaved => _accountSavedController.sink;
  Stream<bool> get saved => _accountSavedController.stream;

  LoginBloc() {
    _saveAccountController.stream.listen(_handleSaveAccount);
  }

  @override
  void dispose() {
    _fetchAccountController.close();
    _saveAccountController.close();
    _accountSavedController.close();
  }

  fetchAccount() async {
    Account account = await PreferencesProvider.get().getAccount();
    inFetchAccount.add(account);
  }

  void _handleSaveAccount(Account account) async {
    await PreferencesProvider.get().saveAccount(account);

    _inSaved.add(true);
  }
}
