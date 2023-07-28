import 'package:flutter/material.dart';
import 'package:petrolshare/routes/authenticate/SignIn.dart';

class AuthenticateRoute extends StatefulWidget {
  @override
  _AuthenticateRouteState createState() => _AuthenticateRouteState();
}

class _AuthenticateRouteState extends State<AuthenticateRoute> {
  static const String _title = 'Petrolshare';
  final ThemeData theme = ThemeData();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Container(child: SignIn()),
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        colorScheme: theme.colorScheme
            .copyWith(secondary: Colors.deepOrange[300], primary: Colors.white),
        textTheme: Typography.blackCupertino,
        primaryTextTheme: Typography.blackCupertino,
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
        ),
      ),
    );
  }
}
