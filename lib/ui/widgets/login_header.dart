import 'package:flutter/material.dart';
import 'package:uproplus/ui/shared/ui_helpers.dart';
import 'package:uproplus/ui/widgets/login_textfield.dart';

class LoginHeader extends StatelessWidget {
  final TextEditingController userNameController;
  final TextEditingController passwordController;
  final String validationMessage;

  LoginHeader({
    @required this.userNameController,
    @required this.passwordController,
    this.validationMessage
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          Image.asset('assets/icons/logo_upro.png'),
          UIHelper.verticalSpaceLarge(),
          LoginTextField(userNameController, 'ユーザー名', false),
          LoginTextField(passwordController, 'パスワード', true),
          UIHelper.verticalSpaceMedium(),
          this.validationMessage != null
              ? Text(validationMessage, style: TextStyle(color: Colors.red))
              : Container()
        ]
    );
  }
}
