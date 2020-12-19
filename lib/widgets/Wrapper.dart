import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/routes/home/HomeRoute.dart';
import 'package:petrolshare/routes/authenticate/AuthenticateRoute.dart';
import 'package:petrolshare/states/Pool.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  final routeObserver = RouteObserver<PageRoute>();
  static const String _title = 'Petrolshare';

  @override
  Widget build(BuildContext context) {
    //_auth.signInSilentlyGoogle(); Why is this here

    print("built wrapper");

    return Consumer<UserModel>(builder: (_, user, child) {
      if (user == null)
        return AuthenticateRoute();
      else
        return ChangeNotifierProvider(
          create: (context) => Pool(user),
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
        );
    });
  }
}
