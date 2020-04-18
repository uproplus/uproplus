import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uproplus/core/models/account.dart';

class PreferencesProvider {
  PreferencesProvider._();

  static final PreferencesProvider _refsProvider = PreferencesProvider._();

  SharedPreferences _prefs;

  static PreferencesProvider get() {
    return _refsProvider;
  }

  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) _prefs = await _initPreferences();
    return _prefs;
  }

  Future<SharedPreferences> _initPreferences() async {
    return SharedPreferences.getInstance();
  }

  Future<Account> getAccount() async {
    SharedPreferences prefs = await _getPrefs();
    String accountString = prefs.getString('account');
    Map<String, dynamic> raw = json.decode(accountString);
    return Account.fromMap(raw);
  }

  saveAccount(Account account) async {
    SharedPreferences prefs = await _getPrefs();
    prefs.setString('account', json.encode(account.toMap()));
  }

  deleteAccount() async {
    SharedPreferences prefs = await _getPrefs();
    prefs.remove('account');
  }

  Future<String> getNews() async {
    SharedPreferences prefs = await _getPrefs();
    return prefs.getString('news');
  }

  saveNews(String news) async {
    SharedPreferences prefs = await _getPrefs();
    prefs.setString('news', news);
  }

  deleteNews() async {
    SharedPreferences prefs = await _getPrefs();
    prefs.remove('news');
  }
}
