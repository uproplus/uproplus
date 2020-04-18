import 'package:flutter/material.dart';
import 'package:uproplus/ui/views/base_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RemoteView extends StatelessWidget {
  final String url;
  final String screenOnExit;

  RemoteView({this.url, this.screenOnExit});

  @override
  Widget build(BuildContext context) {
    print("RemoteView url: $url screenOnExit: $screenOnExit");
    return WillPopScope(
      onWillPop: () => _exitOrSwitchScreen(context),
      child: BaseView(
        body: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _exitOrSwitchScreen(context),
          child: Icon(Icons.transit_enterexit),
        ),
      ),
    );
  }

  Future<bool> _exitOrSwitchScreen(BuildContext context) {
    if (screenOnExit == null || screenOnExit.isEmpty) {
      print("RemoteView exiting");
      Navigator.of(context).pop();
    } else {
      print("RemoteView exiting to: $screenOnExit");
      Navigator.of(context).pushReplacementNamed(screenOnExit);
    }
    return Future.value(false);
  }
}
