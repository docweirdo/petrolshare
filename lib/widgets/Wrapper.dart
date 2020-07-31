
import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/routes/home/HomeRoute.dart';
import 'package:petrolshare/routes/authenticate/AuthenticateRoute.dart';
import 'package:petrolshare/states/Pool.dart';
import 'package:provider/provider.dart';
import 'package:petrolshare/services/auth.dart';


class Wrapper extends StatelessWidget{

  final AuthSevice _auth = AuthSevice();

  @override
  Widget build(BuildContext context){

  
    //_auth.signInSilentlyGoogle(); Why is this here

    print("built wrapper");
    
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