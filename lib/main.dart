import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/widgets/Wrapper.dart';
import 'package:provider/provider.dart';
import 'package:petrolshare/services/auth.dart';

final routeObserver = RouteObserver<PageRoute>();

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Petrolshare';

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel>.value(
      value: AuthSevice().user,
      child: MaterialApp(
        title: _title,
        home: Wrapper(),
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
        theme: ThemeData(
          primaryColor: Colors.white,
          accentColor: Colors.deepOrange[300],
          primaryTextTheme: Typography.blackCupertino,
          textTheme: Typography.blackCupertino
        ),
      ),
    );
  }
}