import 'package:flutter/material.dart';
import 'package:uproplus/core/services/user_service.dart';

class UserItemView extends StatefulWidget {

  final UserItem userItem;
  final bool isCheckBoxVisible;

  UserItemView({
    @required this.userItem,
    @required this.isCheckBoxVisible,
  });

  @override
  _UserItemViewState createState() => _UserItemViewState();
}

class _UserItemViewState extends State<UserItemView> {

  @override
  Widget build(BuildContext context) {
    return widget.isCheckBoxVisible ?
    CheckboxListTile(
      value: widget.userItem.isChecked,
      onChanged: (val) => setState(() => widget.userItem.isChecked = val),
      title: Text(widget.userItem.user.name),
    ) :
    SizedBox();
  }

}

class UserItem {

  final User user;
  bool isChecked;

  UserItem({
    @required this.user,
    this.isChecked,
  });

}
