import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uproplus/core/services/user_service.dart';
import 'package:uproplus/locator.dart';
import 'package:uproplus/ui/router.dart';
import 'package:uproplus/ui/shared/app_colors.dart';

Future<bool> _isLoggedIn() async {
  return await locator<UserService>().init();
}

Future _runAppAsync() async {
  var initialRoute = await _isLoggedIn() ? '/' : 'login';
  runApp(MyApp(initialRoute));
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  _runAppAsync();
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp(this.initialRoute);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          accentColor: Color(0xffa67c00),
          primarySwatch: materialGoldColor),
      initialRoute: initialRoute,
      onGenerateRoute: Router.generateRoute,
    );
  }
}
