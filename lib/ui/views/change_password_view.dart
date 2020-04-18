import 'package:flutter/material.dart';
import 'package:uproplus/core/enums/viewstate.dart';
import 'package:uproplus/core/viewmodels/login_model.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/shared/text_styles.dart';
import 'package:uproplus/ui/shared/ui_helpers.dart';
import 'package:uproplus/ui/widgets/login_textfield.dart';

import 'base_view_notifier.dart';

class ChangePasswordView extends StatefulWidget {
  ChangePasswordView({Key key, @required this.userName}) : super(key: key);

  final String userName;

  @override
  _ChangePasswordViewState createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseViewNotifier<LoginModel>(
        builder: (context, model, child) => Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                      children: <Widget>[
                        Image.asset('assets/icons/logo_upro.png'),
                        UIHelper.verticalSpaceLarge(),
                        LoginTextField(_oldPasswordController, '旧パスワード', true),
                        LoginTextField(_newPasswordController, '新しいパスワード', true),
                        LoginTextField(_confirmNewPasswordController, '新しいパスワード一致', true),
                        UIHelper.verticalSpaceMedium(),
                      ]
                  ),
                  model.state == ViewState.Busy
                      ? CircularProgressIndicator()
                      : FlatButton(
                    color: goldColor,
                    child: Text(
                      'Login',
                      style: buttonStyle,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState != null) {
                        _formKey.currentState.save();
                      }
                      if (_oldPasswordController.text != _newPasswordController.text) {
                        _showErrorMessage(context, '新しいパスワードが一致しません');
                        return;
                      }
                      var response = await model.changePassword(widget.userName, _oldPasswordController.text, _newPasswordController.text);
                      if (response is ChangePasswordResultState) {
                        Navigator.of(context).pop(true);
                      } else if (response is ChangePasswordErrorState) {
                        _showErrorMessage(context, response.message);
                      }
                    },
                  )
                ],
              );
            },
          )
        ),
    );
  }

  void _showErrorMessage(BuildContext context, String errorMessage) {
    final snackBar = new SnackBar(
      content: new Text(errorMessage),
      duration: new Duration(seconds: 10),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }
}
