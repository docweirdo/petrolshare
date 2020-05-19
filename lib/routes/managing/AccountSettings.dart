

import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/widgets/NameAndIcon.dart';

class AccountSettings extends StatelessWidget {

  final Function logoutCallback;

  final UserModel user;

  AccountSettings(this.user, this.logoutCallback);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Column(
        children: <Widget>[
          NameAndIcon(user, logoutCallback),
        ]
      ),
    );
  }
}