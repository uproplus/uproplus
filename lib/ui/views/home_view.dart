import 'package:flutter/material.dart';
import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/data/blocs/home_bloc.dart';
import 'package:uproplus/ui/views/base_view.dart';
import 'package:uproplus/ui/widgets/home_button.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  HomeBloc _homeBloc;

  @override
  void initState() {
    _homeBloc = BlocProvider.of<HomeBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
        body: Container(
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(2.0),
                          child: HomeButtonView(
                            icon: Icon(
                              Icons.play_circle_outline,
                              color: Colors.black,
                            ),
                            japaneseText: "再生",
                            englishText: "PLAY",
                            onPressedListener: () => Navigator.pushNamed(context, 'play'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(2.0),
                          child: HomeButtonView(
                            icon: Icon(
                              Icons.settings,
                              color: Colors.black,
                            ),
                            japaneseText: "編集",
                            englishText: "EDIT",
                            onPressedListener: () => Navigator.pushNamed(context, 'edit_list'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(2.0),
                          child: HomeButtonView(
                            icon: ImageIcon(
                              AssetImage('assets/icons/change_plan.png'),
                              color: Colors.black,
                            ),
                            japaneseText: "プラン変更",
                            englishText: "PLAN CHANGE",
                            onPressedListener: () => Navigator.pushNamed(context, 'remote_view', arguments: ['https://u-pro.plus/request']),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(2.0),
                          child: HomeButtonView(
                            icon: Icon(
                              Icons.mail_outline,
                              color: Colors.black,
                            ),
                            japaneseText: "お問い合わせ",
                            englishText: "CONTACT",
                            onPressedListener: () => Navigator.pushNamed(context, 'remote_view', arguments: ['https://u-pro.plus/contact']),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(2.0),
                          child: HomeButtonView(
                            icon: ImageIcon(
                              AssetImage('assets/icons/logout.png'),
                              color: Colors.black,
                            ),
                            japaneseText: "ログアウト",
                            englishText: "LOGOUT",
                            onPressedListener: () {
                              _homeBloc.logout();
                              _homeBloc.loggedOut.listen((loggedOut) {
                                if (loggedOut) {
                                  Navigator.pushReplacementNamed(context, 'login');
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
        ),
    );
  }
}
