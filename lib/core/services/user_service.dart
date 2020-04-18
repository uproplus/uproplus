import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart'
;import 'package:mime/mime.dart';

import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uproplus/core/models/ApiResponse.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:validators/validators.dart';

const _awsUserPoolId = 'ap-northeast-1_wQe96UY6B';
const _awsClientId = '43jsk9s7uj9llqhdrm94hm96ae';

const aws_endpoint = 'https://sztn9kyfo6.execute-api.ap-northeast-1.amazonaws.com/dev/';
const s3_endpoint = 'https://u-pro-plus.s3-ap-northeast-1.amazonaws.com/';

final adminGroups = Set.from(['admingrouptest', 'admingroup']);

final userPool = new CognitoUserPool(_awsUserPoolId, _awsClientId);

Map<String, dynamic> _parseJwt(String _token) {
  final parts = _token.split('.');
  if (parts.length != 3) {
    throw Exception('invalid token');
  }

  final payload = _decodeBase64(parts[1]);
  final payloadMap = json.decode(payload);
  if (payloadMap is! Map<String, dynamic>) {
    throw Exception('invalid payload');
  }

  return payloadMap;
}

String _decodeBase64(String _str) {
  String output = _str.replaceAll('-', '+').replaceAll('_', '/');

  switch (output.length % 4) {
    case 0:
      break;
    case 2:
      output += '==';
      break;
    case 3:
      output += '=';
      break;
    default:
      throw Exception('Illegal base64url string!"');
  }

  return utf8.decode(base64Url.decode(output));
}

class Storage extends CognitoStorage {
  SharedPreferences _prefs;
  Storage(this._prefs);

  @override
  Future getItem(String key) async {
    String item;
    try {
      item = json.decode(_prefs.getString(key));
    } catch (e) {
      return null;
    }
    return item;
  }

  @override
  Future setItem(String key, value) async {
    _prefs.setString(key, json.encode(value));
    return getItem(key);
  }

  @override
  Future removeItem(String key) async {
    final item = getItem(key);
    if (item != null) {
      _prefs.remove(key);
      return item;
    }
    return null;
  }

  @override
  Future<void> clear() async {
    _prefs.clear();
  }
}

class User {
  String userName;
  String email;
  String name;
  Set<String> groups = Set();
  int deviceAllocation;

  User(this.userName, {this.email, this.name});

  bool isAdmin() => groups.intersection(adminGroups).isNotEmpty;

  /// Decode user from Cognito User Attributes
  factory User.fromUserAttributes(String userName, List<CognitoUserAttribute> attributes) {
    final user = User(userName);
    attributes.forEach((attribute) {
      print("User.fromUserAttributes ${attribute.getName()} : ${attribute.getValue()}");
      if (attribute.getName() == 'email') {
        user.email = attribute.getValue();
      } else if (attribute.getName() == 'name') {
        user.name = attribute.getValue();
      }
    });
    return user;
  }

  factory User.fromUserToken(String userName, String jwtToken) {
    print(jwtToken);

    final user = User(userName);

    var token = _parseJwt(jwtToken);
    print(token);

    token.forEach((key, value) {
      if (key == 'email') {
        user.email = value;
      } else if (key == 'cognito:username') {
        user.name = value;
      } else if (key == 'cognito:groups') {
        if (value is Iterable) {
          value.forEach((group) {
            user.groups.add(group.toString());
          });
        } else {
          user.groups.add(value);
        }
      }
    });
    return user;
  }

  factory User.fromUserTokenPayload(dynamic payload) {
    print(payload);

    final user = User(
        payload['cognito:username'],
        email: payload['email']
    );
    user.deviceAllocation = payload['deviceAllocation'];

    payload.forEach((key, value) {
      if (key == 'cognito:groups') {
        if (value is Iterable) {
          value.forEach((group) {
            user.groups.add(group.toString());
          });
        } else {
          user.groups.add(value);
        }
      }
    });
    return user;
  }
}

class UserService {
  CognitoUserPool _userPool;
  CognitoUser _cognitoUser;
  CognitoUserSession _session;
  CognitoCredentials credentials;
  var httpClient = new http.Client();

  UserService(this._userPool);

  /// Initiate user session from local storage if present
  Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = new Storage(prefs);
    _userPool.storage = storage;

    _cognitoUser = await _userPool.getCurrentUser();
    if (_cognitoUser == null) {
      return false;
    }
    _session = await _cognitoUser.getSession();
    print(_session.idToken.jwtToken);
    return _session.isValid();
  }

  Future<User> login(String userName, String password) async {
    _cognitoUser =
    new CognitoUser(userName, _userPool, storage: _userPool.storage);

    final authDetails = new AuthenticationDetails(
      username: userName,
      password: password,
    );

    _session = await _cognitoUser.authenticateUser(authDetails);

    if (!_session.isValid()) {
      return null;
    }
    return getUser();
  }

  User getUser() {
//    final attributes = await _cognitoUser.getUserAttributes();
//    return User.fromUserAttributes(attributes);
//    return User.fromUserToken(_session.idToken.jwtToken);
    return User.fromUserTokenPayload(_session.idToken.payload);
  }

  bool isUserAdmin() {
    return getUser().isAdmin();
  }

  bool isAdmin(String user) {
    return adminGroups.contains(user);
  }

  bool isUser(String user) {
    return getUser().userName == user;
  }

  Future<void> logout() async {
    final keyPrefix =
        'CognitoIdentityServiceProvider.${_userPool.getClientId()}.${_cognitoUser.username}';
    final deviceKeyKey = '$keyPrefix.deviceKey';
    var deviceKey = await _userPool.storage.getItem(deviceKeyKey);
    var body = {
      "userName": _cognitoUser.username,
      "userPoolId": _userPool.getUserPoolId(),
      "deviceKey": deviceKey,
    };
    print(body);
    await _post("signout", body: body);
    return await _cognitoUser.signOut();
  }

  Future<void> completeNewPasswordChallenge(String newPassword) async {
    return await _cognitoUser.completeNewPasswordChallenge(newPassword);
  }

  Future<bool> changePassword(String userName, String oldPassword, String newPassword) async {
    _cognitoUser =
    new CognitoUser(userName, _userPool, storage: _userPool.storage);

    return await _cognitoUser.changePassword(oldPassword, newPassword);
  }

  Future<List<User>> getUserList() async {
    var groups = getUser().groups.difference(adminGroups);
    if (groups.isEmpty) {
      return [];
    }
    var body = {
      "groupName": groups.first,
      "userPoolId": _userPool.getUserPoolId()
    };
    print(body);
    var apiResponse = await _post("userlist", body: body);
    if (apiResponse.code != 'OK') {
      return [];
    }

    print(apiResponse.message);

    var userList = List<User>();

    apiResponse.message.forEach( (userResponse) {
      var userName = userResponse['userName'];
      var user = User(userName, email: userResponse['email']);
      user.deviceAllocation = userResponse['deviceAllocation'];
      userList.add(user);
    });

    return userList;
  }

  Future<dynamic> downloadAds() async {
    var groups = getUser().groups.difference(adminGroups);
    if (groups.isEmpty) {
      return [];
    }
    var body = {
      "groupName": groups.first,
      "userPoolId": _userPool.getUserPoolId()
    };
    print(body);
    final apiResponse = await _post("listads", body: body);
    if (apiResponse.code != 'OK') {
      return Future.error(apiResponse.message);
    }

    return apiResponse.message;
  }

  Future<Ad> uploadAd(Ad ad) async {
    var user = getUser();
    var groups = user.groups.difference(adminGroups);
    if (groups.isEmpty) {
      return Future.error('no group');
    }

    if (ad.owner?.isEmpty ?? true) {
      ad.owner = user.userName;
    }

    if ((ad.mediaPath?.isNotEmpty ?? false) && !isURL(ad.mediaPath)) {
      var mediaFileName = "${groups.first}/${user.userName}/${basename(ad.mediaPath)}";
      ad.mediaPath = await _uploadFile(MediaType.parse(lookupMimeType(ad.mediaPath)), ad.mediaPath, mediaFileName);
    }

    if ((ad.thumbnailPath?.isNotEmpty ?? false) && !isURL(ad.thumbnailPath)) {
      var mediaFileName = "${groups.first}/${user.userName}/${basename(ad.thumbnailPath)}";
      ad.thumbnailPath = await _uploadFile(MediaType.parse(lookupMimeType(ad.thumbnailPath)), ad.thumbnailPath, mediaFileName);
    }

    final adMap = ad.toMap();
    if (ad.childAds != null) {
      adMap['child_ids'] = ad.childAds.map((child) => child.id).toList();
    }
    print(adMap);
    var apiResponse = await _post("savead", body: adMap);
    if (apiResponse.code != 'OK') {
      return Future.error(apiResponse.message);
    }

    return Future.value(ad);
  }

  Future deleteAd(Ad ad) async {
    final adMap = ad.toMap();
    if (ad.childAds != null) {
      adMap['child_ids'] = ad.childAds.map((child) => child.id).toList();
    }
    print(adMap);
    var apiResponse = await _post("deletead", body: adMap);
    if (apiResponse.code != 'OK') {
      return Future.error(apiResponse.message);
    }
  }

  Future _uploadFile(MediaType mediaType, String localMediaPath, String mediaFileName) async {
    print(mediaType);
    print(localMediaPath);
    var body = {
      "key": mediaFileName,
      "type": mediaType.toString()
    };
    var apiResponse = await _post("createsignedfileurl", body: body);
    if (apiResponse.code != 'OK') {
      return Future.error(apiResponse.message);
    }

    var signedS3FileUrl = apiResponse.message;
    print(signedS3FileUrl);
    var signedS3FileUri = Uri.parse(signedS3FileUrl);
    print(signedS3FileUri.queryParameters);

    final file = File(localMediaPath);
    final fileStream = file.openRead();
    int totalByteLength = file.lengthSync();

    final request = await HttpClient().putUrl(signedS3FileUri);
    request.headers.set(HttpHeaders.contentTypeHeader, mediaType.toString());
    request.headers.add("filename", basename(file.path));
    request.contentLength = totalByteLength;

    Stream<List<int>> streamUpload = fileStream.transform(
      new StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);
        },
        handleError: (error, stack, sink) {
          print(error.toString());
        },
        handleDone: (sink) {
          sink.close();
        },
      ),
    );

    await request.addStream(streamUpload);

    final response = await request.close();

    if (response.statusCode != 200) {
      return Future.error(response.statusCode);
    }

    return Future.value("$s3_endpoint$mediaFileName");
  }

  Future<dynamic> saveNews(String news) async {
    var groups = getUser().groups.difference(adminGroups);
    if (groups.isEmpty) {
      return [];
    }
    var body = {
      "groupName": groups.first,
      "userPoolId": _userPool.getUserPoolId(),
      "news": news
    };
    print(body);
    final apiResponse = await _post("savenews", body: body);
    if (apiResponse.code != 'OK') {
      return Future.error(apiResponse.message);
    }

    return apiResponse.message;
  }

  Future<String> getNews() async {
    var body = {
      "userName": getUser().userName
    };
    print(body);
    final apiResponse = await _post("getnews", body: body);
    if (apiResponse.code != 'OK') {
      return '';
    }

    return apiResponse.message;
  }

  Future<ApiResponse> _post(String path, {dynamic body}) async {
    var response = await httpClient.post(
        "$aws_endpoint/$path",
        headers: {
          "Authorization": _session.idToken.jwtToken,
          "Content-Type": "application/json; charset=utf-8"
        },
        body: json.encode(body)
    );
    return ApiResponse.fromMappedJson(json.decode(utf8.decode(response.bodyBytes)));
  }
}
