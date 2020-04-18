import 'package:flutter/material.dart';
import 'package:uproplus/core/data/blocs/admin_bloc.dart';
import 'package:uproplus/core/data/blocs/bloc_provider.dart';
import 'package:uproplus/core/services/user_service.dart';
import 'package:uproplus/ui/shared/app_colors.dart';


class AdminView extends StatefulWidget {
  AdminView({Key key}) : super(key: key);

  @override
  _AdminViewState createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  AdminBloc _adminBloc;

  User _admin;

  @override
  void initState() {
    _adminBloc = BlocProvider.of<AdminBloc>(context);
    super.initState();

    _adminBloc.fetchUserList();
    _admin = _adminBloc.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ユーザー一覧',
      home: Scaffold(
        appBar: AppBar(
          title: Text('ユーザー一覧'),
          backgroundColor: goldColor,
          actions: [
            FlatButton(
              child: Text('閉じる'),
              textColor: Colors.white,
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              },
            ),
          ],
        ),
        body: StreamBuilder<List<User>>(
          stream: _adminBloc.fetched,
          builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {

            if (snapshot.hasData) {
              return _myListView([]..addAll(snapshot.data));
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          }
        ),
      ),
    );
  }

  Widget _myListView(List<User> users) {
    if (users.isEmpty) {
      return Container();
    }
    User admin = users.firstWhere((user) {
      return user.userName == _admin.userName;
    });
    print(admin);
    if (admin == null) {
      return Container();
    }
    users.remove(admin);
    // backing data
    return Container(
      child: Column(
        children: [
          ListTile(
              title: Text(admin.userName),
              subtitle: Text(admin.email),
              trailing: RichText(
                text: TextSpan(
                  // Note: Styles for TextSpans must be explicitly defined.
                  // Child text spans will inherit styles from parent
                  style: new TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    new TextSpan(text: 'デバイス割当合計:  ', style: new TextStyle(fontWeight: FontWeight.bold)),
                    new TextSpan(text: admin.deviceAllocation.toString()),
                  ],
                ),
              )
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users == null ? 1 : users.length + 1,
              itemBuilder: (context, index) {
                return index == 0 ?
                ListTile(
                  title: Text('ユーザー名', style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text('メール', style: TextStyle(fontWeight: FontWeight.bold),),
                  trailing: Text('デバイス割当', style: TextStyle(fontWeight: FontWeight.bold),),
                ) : ListTile(
                  title: Text(users[index - 1].userName),
                  subtitle: Text(users[index - 1].email),
                  trailing: Text(users[index - 1].deviceAllocation.toString()),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
