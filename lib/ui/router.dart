import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uproplus/core/data/blocs/ad_bloc.dart';
import 'package:uproplus/core/data/blocs/admin_bloc.dart';
import 'package:uproplus/core/data/blocs/ads_bloc.dart';
import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/data/blocs/home_bloc.dart';
import 'package:uproplus/core/data/blocs/login_bloc.dart';
import 'package:uproplus/core/data/blocs/multi_ad_bloc.dart';
import 'package:uproplus/core/models/ad.dart';
import 'package:uproplus/ui/views/add_image_view.dart';
import 'package:uproplus/ui/views/add_rss_view.dart';
import 'package:uproplus/ui/views/add_video_view.dart';
import 'package:uproplus/ui/views/admin_view.dart';
import 'package:uproplus/ui/views/change_password_view.dart';
import 'package:uproplus/ui/views/edit_image_view.dart';
import 'package:uproplus/ui/views/edit_multi_view.dart';
import 'package:uproplus/ui/views/edit_rss_view.dart';
import 'package:uproplus/ui/views/edit_video_view.dart';
import 'package:uproplus/ui/views/edit_grid_view.dart';
import 'package:uproplus/ui/views/home_view.dart';
import 'package:uproplus/ui/views/login_view.dart';
import 'package:uproplus/ui/views/new_password_view.dart';
import 'package:uproplus/ui/views/play_view.dart';
import 'package:uproplus/ui/views/remote_view.dart';

const String initialRoute = "/";

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: HomeBloc(),
                child: HomeView()
            )
        );
      case 'admin':
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: AdminBloc(),
                child: AdminView()
            )
        );
      case 'login':
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: LoginBloc(),
                child: LoginView()
            )
        );
      case 'new_password':
        var userName = settings.arguments as String;
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: LoginBloc(),
                child: NewPasswordView(userName: userName)
            )
        );
      case 'change_password':
        var userName = settings.arguments as String;
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: LoginBloc(),
                child: ChangePasswordView(userName: userName)
            )
        );
      case 'play':
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: AdsBloc(),
                child: PlayView()
            )
        );
      case 'edit_list':
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: AdsBloc(),
                child: EditGridView()
            )
        );
      case 'edit_ad_image':
        var ad = settings.arguments as Ad;
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: AdBloc(),
                child: EditImageView(ad: ad)
            )
        );
      case 'edit_ad_video':
        var ad = settings.arguments as Ad;
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: AdBloc(),
                child: EditVideoView(ad: ad)
            )
        );
      case 'edit_ad_rss':
        var ad = settings.arguments as Ad;
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: AdBloc(),
                child: EditRssView(ad: ad)
            )
        );
      case 'edit_ad_multi':
        var ad = settings.arguments as Ad;
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: MultiAdBloc(),
                child: EditMultiView(ad: ad)
            )
        );
      case 'add_ad_image':
        var ad = settings.arguments as Ad;
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: AdBloc(),
                child: AddImageView(ad: ad)
            )
        );
      case 'add_ad_video':
        var ad = settings.arguments as Ad;
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: AdBloc(),
                child: AddVideoView(ad: ad)
            )
        );
      case 'add_ad_rss':
        var ad = settings.arguments as Ad;
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: AdBloc(),
                child: AddRssView(ad: ad)
            )
        );
      case 'remote_view':
        final params = settings.arguments as List<String>;
        final String url = params[0];
        final String screenOnExit = params.length >= 2 ? params[1] : null;
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
                bloc: AdBloc(),
                child: RemoteView(url: url, screenOnExit: screenOnExit,)
            )
        );
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ));
    }
  }
}
