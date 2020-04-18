import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:uproplus/core/enums/viewstate.dart';
import 'package:uproplus/core/services/user_service.dart';
import 'package:uproplus/core/viewmodels/base_model.dart';

import '../../locator.dart';

class LoginModel extends BaseModel {
  final UserService _userService = locator<UserService>();

  String errorMessage;

  User getUser() {
    return _userService.getUser();
  }

  Future<LoginResponse> login(String userName, String password) async {
    setState(ViewState.Busy);
    try {
      if (_isNullOrEmpty(userName) || _isNullOrEmpty(password)) {
        return LoginResponse.error('empty_input', 'ユーザー名またはパスワードを入力してください');
      }
      var user = await _userService.login(userName, password);
      return user == null
          ? LoginResponse.error('expired_session', 'セッションの期限が切れました。再ログインしてください。')
          : LoginResponse.result(user);
    } on CognitoUserNewPasswordRequiredException catch (e) {
      return LoginResponse.error('new_password', e.message);
    } on CognitoClientException catch (e) {
      print(e);
      if (e.code == 'NotAuthorizedException') {
        return LoginResponse.error(e.code, 'ユーザー名またはパスワードが間違っています');
      } else if (e.code == 'UserNotFoundException') {
        return LoginResponse.error(e.code, 'ユーザ名が見つかりません');
      } else if (e.code == 'InvalidParameterException') {
        return LoginResponse.error(e.code, 'システム管理者に連絡してください');
      } else if (e.code == 'ResourceNotFoundException') {
        return LoginResponse.error(e.code, 'システム管理者に連絡してください');
      } else if (e.code == 'UserNotConfirmedException') {
        return LoginResponse.error(e.code, 'ユーザーは確認されていません。メールをチェックしてください。');
      } else if (e.code == 'UserLambdaValidationException') {
        return LoginResponse.error(e.code, '最大許容デバイスが制限を超えています');
      } else {
        return LoginResponse.error(e.code, 'ログインできません');
      }
    } on CognitoUserException catch (e) {
      print(e);
      return LoginResponse.error('change_password', 'パスワードを変更してください');
    } catch (e) {
      print(e);
      return LoginResponse.error(e.toString(), 'ログインできません');
    } finally {
      setState(ViewState.Idle);
    }
  }

  Future<void> completeNewPasswordChallenge(String userName, String oldPassword, String newPassword) async {
    print("changePassword $userName, $oldPassword, $newPassword");
    setState(ViewState.Busy);
    try {
      await _userService.completeNewPasswordChallenge(newPassword);
    } catch (e) {
      print(e);
      return false;
    } finally {
      setState(ViewState.Idle);
    }
  }

  Future<ChangePasswordResponse> changePassword(String userName, String oldPassword, String newPassword) async {
    print("changePassword $userName, $oldPassword, $newPassword");
    setState(ViewState.Busy);
    try {
      await _userService.changePassword(userName, oldPassword, newPassword);
      return ChangePasswordResponse.result();
    } on CognitoClientException catch(e) {
      print(e);
      return ChangePasswordResponse.error(e.code, e.message);
    } catch (e) {
      print(e);
      return ChangePasswordResponse.error(e.toString(), 'パスワード更新が失敗しました。');
    } finally {
      setState(ViewState.Idle);
    }
  }

  bool _isNullOrEmpty(String text) => text == null || text.isEmpty;
}

class LoginResponse {
  LoginResponse._();

  factory LoginResponse.result(User user) = LoginResultState;
  factory LoginResponse.error(String code, String message) = LoginErrorState;
}

class LoginResultState extends LoginResponse {
  LoginResultState(this.user): super._();

  final User user;
}

class LoginErrorState extends LoginResponse {
  LoginErrorState(this.code, this.message): super._();

  final String code;
  final String message;
}

class ChangePasswordResponse {
  ChangePasswordResponse._();

  factory ChangePasswordResponse.result() = ChangePasswordResultState;
  factory ChangePasswordResponse.error(String code, String message) = ChangePasswordErrorState;
}

class ChangePasswordResultState extends ChangePasswordResponse {
  ChangePasswordResultState(): super._();
}

class ChangePasswordErrorState extends ChangePasswordResponse {
  ChangePasswordErrorState(this.code, this.message): super._();

  final String code;
  final String message;
}
