import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
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
      else //TODO: ProxyPovider might be replacable by normal Provider using user in Constructor
        return ProxyProvider<FirebaseUser, AppState>(
          create: (context) => AppState(),
          update: (_, firebaseUser, appState) => appState..update(firebaseUser),
          child: ChangeNotifierProxyProvider<AppState, Pool>(
            create: (context) => Pool(),
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
