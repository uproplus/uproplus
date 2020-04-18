import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseView extends Scaffold {

  final Widget body;
  final Color backgroundColor;
  final Widget floatingActionButton;

  BaseView({this.body, this.backgroundColor, this.floatingActionButton}) : super(
      body: body,
      backgroundColor: backgroundColor == null ? Colors.black : backgroundColor,
      floatingActionButton: floatingActionButton
  );

  @override
  _BaseViewState createState() => _BaseViewState();
}

class _BaseViewState extends ScaffoldState {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return Container(
        child: GestureDetector(
            onTap: () { FocusScope.of(context).requestFocus(FocusNode()); },
            child: super.build(context)
        )
    );
  }
}
