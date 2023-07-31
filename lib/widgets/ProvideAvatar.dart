

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrolshare/models/UserModel.dart';

class ProvideAvatar extends StatelessWidget{

  final UserModel user;

  ProvideAvatar(this.user);

  @override
  Widget build(BuildContext context){

    final Uint8List? photoBytes = user.photoBytes;
    
    if (photoBytes == null) {
      return CircleAvatar(
          backgroundColor: Colors.grey[100],
          //foregroundColor: Theme.of(context).accentColor,
          radius: 28,
          child: Text(user.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              )));
    }
    return CircleAvatar(
      backgroundImage: MemoryImage(photoBytes),
      radius: 28,
    );
  }

}