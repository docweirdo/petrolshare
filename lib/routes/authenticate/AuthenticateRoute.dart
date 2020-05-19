import 'package:flutter/material.dart';
import 'package:petrolshare/routes/authenticate/SignIn.dart';

class AuthenticateRoute extends StatefulWidget {
  @override
  _AuthenticateRouteState createState() => _AuthenticateRouteState();
}

class _AuthenticateRouteState extends State<AuthenticateRoute> {
  @override
  Widget build(BuildContext context){
    return Container(
      child: SignIn(),
    );
  }
}