import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/services/auth.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  
  final AuthSevice _auth = AuthSevice();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Petrolshare'),
        centerTitle: true,
        elevation: 1.0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Card(
          child: Container(
            margin: EdgeInsets.all(100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                OutlineButton.icon(
                  label: Text('GOOGLE'),
                  icon: Icon(Icons.supervised_user_circle),
                  textColor: Theme.of(context).accentColor,
                  onPressed: () async {
                    dynamic result = await _auth.signInGoogle();
                    if (result == null){
                      print('error signing in');
                    } else {
                      print('signed in');
                      print(result);
                    }
                  },
                ),
                OutlineButton.icon(
                  label: Text('EMAIL'),
                  icon: Icon(Icons.email),
                  textColor: Theme.of(context).accentColor,
                  onPressed: () async {
                    FirebaseUser result = await _auth.signInAnon();
                    if (result == null){
                      print('error signing in');
                    } else {
                      print('signed in');
                      print(result.uid);
                    }
                  },
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: FlatButton(
                    child: Text('Skip'),
                    onPressed: () async {
                      dynamic result = await _auth.signInAnon();
                      if (result == null){
                        print('error signing in');
                      } else {
                        print('signed in');
                        print(result.uid);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ) 
    );
  }
}