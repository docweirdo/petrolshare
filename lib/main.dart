import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/Wrapper.dart';
import 'package:provider/provider.dart';
import 'package:petrolshare/services/auth.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
      value: AuthSevice().user,
      child: Wrapper(),
    );
  }
}
