import 'dart:async';

import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/services/user_service.dart';
import 'package:uproplus/locator.dart';

class AdminBloc implements BlocBase {

  final _fetchAdminController = StreamController<List<User>>.broadcast();
  StreamSink<List<User>> get inFetchAdmin => _fetchAdminController.sink;
  Stream<List<User>> get fetched => _fetchAdminController.stream;

  final UserService _userService = locator<UserService>();

  AdminBloc();

  @override
  void dispose() {
    _fetchAdminController.close();
  }

  fetchUserList() async {
    List<User> userList = await _userService.getUserList();
    print('fetchUserList');
    inFetchAdmin.add(userList);
  }

  User getUser() {
    return _userService.getUser();
  }
}
