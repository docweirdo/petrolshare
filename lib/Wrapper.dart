import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/routes/home/HomeRoute.dart';
import 'package:petrolshare/routes/authenticate/AuthenticateRoute.dart';
import 'package:petrolshare/states/AppState.dart';
import 'package:petrolshare/states/Pool.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  final routeObserver = RouteObserver<PageRoute>();
  static const String _title = 'Petrolshare';

  @override
  Widget build(BuildContext context) {
    //_auth.signInSilentlyGoogle(); Why is this here

    print("built wrapper");

    return Consumer<FirebaseUser>(builder: (_, user, child) {
      if (user == null)
        return AuthenticateRoute();
      else
        return ChangeNotifierProvider<AppState>(
          create: (context) => AppState(user),
          child: ChangeNotifierProxyProvider<AppState, PoolState>(
            create: (context) => PoolState(),
            update: (_, appState, pool) => pool..update(appState.selectedPool),
            child: MaterialApp(
              title: _title,
              home: HomeRoute(),
              debugShowCheckedModeBanner: false,
              navigatorObservers: [routeObserver],
              theme: ThemeData(
                primaryColor: Colors.white,
                accentColor: Colors.deepOrange[300],
                primaryTextTheme: Typography.blackCupertino,
                textTheme: Typography.blackCupertino,
                bottomSheetTheme: BottomSheetThemeData(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10))),
                ),
              ),
            ),
          ),
        );
    });
  }
}
