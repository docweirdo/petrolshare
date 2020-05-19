import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:petrolshare/services/auth.dart';

class ManageStrippedTab extends StatelessWidget{
  ManageStrippedTab({Key key}) : super(key: key);

  final AuthSevice _auth = AuthSevice();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        child: Text('Log Out'),
        onPressed: () async {
          await _auth.signOut(); 
        },
      )
    );
  }
  
  
}
