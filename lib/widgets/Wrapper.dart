
import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/routes/home/HomeRoute.dart';
import 'package:petrolshare/routes/authenticate/AuthenticateRoute.dart';
import 'package:petrolshare/states/Pool.dart';
import 'package:provider/provider.dart';


class Wrapper extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    
    return Consumer<UserModel>(
      builder: (_, user, child) {
        if (user == null) return AuthenticateRoute();
        else return ChangeNotifierProvider(
          create: (context) => Pool(user),
          child: HomeRoute(),
        );
      }
    );
  }
}