import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/routes/home/HomeRoute.dart';
import 'package:petrolshare/routes/authenticate/AuthenticateRoute.dart';
import 'package:petrolshare/states/AppState.dart';
import 'package:petrolshare/states/PoolState.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  final routeObserver = RouteObserver<PageRoute>();
  static const String _title = 'Petrolshare';

  @override
  Widget build(BuildContext context) {
    //_auth.signInSilentlyGoogle(); Why is this here

    final ThemeData theme = ThemeData();

    debugPrint("Wrapper: built");

    return Consumer<User?>(builder: (_, user, child) {
      if (user == null)
        return AuthenticateRoute();
      else  
         return ChangeNotifierProvider<AppState>(
          create: (context) => AppState(user),
          child: ChangeNotifierProxyProvider<AppState, PoolState?>(
            create: (context) => PoolState(),
            update: (_, appState, poolState) => poolState
              ?..update(appState.selectedPool,
                  appState.availablePools[appState.selectedPool]),
            child: MaterialApp(
              title: _title,
              home: HomeRoute(),
              debugShowCheckedModeBanner: false,
              navigatorObservers: [routeObserver],
              theme: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(secondary: Colors.deepOrange[300], primary: Colors.white),
                textTheme: Typography.blackCupertino,
                primaryTextTheme: Typography.blackCupertino,
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
