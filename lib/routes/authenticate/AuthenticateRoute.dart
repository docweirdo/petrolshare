import 'package:flutter/material.dart';
import 'package:petrolshare/routes/authenticate/SignIn.dart';

class AuthenticateRoute extends StatefulWidget {
  @override
  _AuthenticateRouteState createState() => _AuthenticateRouteState();
}

class _AuthenticateRouteState extends State<AuthenticateRoute> {
  static const String _title = 'Petrolshare';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Container(child: SignIn()),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.deepOrange[300],
        primaryTextTheme: Typography.blackCupertino,
        textTheme: Typography.blackCupertino,
      ),
    );
  }
}
