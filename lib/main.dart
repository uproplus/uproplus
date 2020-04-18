import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uproplus/ui/router.dart';
import 'package:uproplus/ui/shared/app_colors.dart';

void main() => runApp(MyApp());





class MyApp extends StatelessWidget {


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