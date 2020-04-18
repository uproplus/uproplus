import 'package:flutter/material.dart';
import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/data/blocs/login_bloc.dart';
import 'package:uproplus/core/enums/viewstate.dart';
import 'package:uproplus/core/models/account.dart';
import 'package:uproplus/core/viewmodels/login_model.dart';
import 'package:uproplus/ui/shared/app_colors.dart';
import 'package:uproplus/ui/shared/text_styles.dart';
import 'package:uproplus/ui/widgets/login_header.dart';

import 'base_view_notifier.dart';

class LoginView extends StatefulWidget {
  LoginView({Key key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginBloc _loginBloc;

  @override
  void initState() {
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseViewNotifier<LoginModel>(
        builder: (context, model, child) => Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    StreamBuilder<Account>(
                        stream: _loginBloc.fetched,
                        builder: (BuildContext context, AsyncSnapshot<Account> snapshot) {
                          if (snapshot.hasData) {
                            _userNameController.text = snapshot.data.name;
                          }
                          return LoginHeader(
                            userNameController: _userNameController,
                            passwordController: _passwordController,
                          );
                        }
                    ),
                    model.state == ViewState.Busy
                        ? CircularProgressIndicator()
                        : FlatButton(
                      padding: EdgeInsets.all(10),
                      color: goldColor,
                      child: Text(
                        'Login',
                        style: buttonStyle,
                      ),
                      onPressed: () async {
                        _formKey.currentState.save();
                        var response = await model.login(_userNameController.text, _passwordController.text);
                        if (response is LoginResultState) {
                          print("login success: ${response.user}");
                          _loginBloc.inSaveAccount.add(Account(name: _userNameController.text));
                          _loginBloc.saved.listen((saved) {
                            if (saved) {
//                              if (response.user.isAdmin()) {
//                                Navigator.pushReplacementNamed(context, 'admin');
//                              } else {
                                Navigator.pushReplacementNamed(context, '/');
//                              }
                            }
                          });
                        } else if (response is LoginErrorState) {
                          _showErrorMessage(context, response, _userNameController.text);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          )
        ),
    );
  }

  void _showMessage(BuildContext context, String message, SnackBarAction action, Duration duration) {
    Scaffold.of(context).hideCurrentSnackBar();
    final snackBar = new SnackBar(
      content: Text(message),
      action: action,
      duration: duration,
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _showErrorMessage(BuildContext context, LoginErrorState errorState, String userName) {
    _showMessage(context, errorState.message, _getErrorAction(context, errorState, userName), Duration(seconds: 15));
  }

  SnackBarAction _getErrorAction(BuildContext context, LoginErrorState errorState, String userName) {
    if (errorState.code == 'new_password') {
      return SnackBarAction(
        label: 'パスワードを更新',
        onPressed: () async {
          var success = await Navigator.pushNamed(context, 'new_password', arguments: userName);
          if (success != null) {
            _passwordController.text = '';
            _showMessage(context, 'パスワードを更新しました。再度ログインしてください。', null, Duration(seconds: 10));
          }
        },
      );
    } else if (errorState.code == 'change_password') {
      return SnackBarAction(
        label: 'パスワードを更新',
        onPressed: () async {
          var success = await Navigator.pushNamed(context, 'change_password', arguments: userName);
          if (success != null) {
            _showMessage(context, 'パスワードを更新しました。再度ログインしてください。', null, Duration(seconds: 10));
          }
        },
      );
    }

    return null;
  }
}
