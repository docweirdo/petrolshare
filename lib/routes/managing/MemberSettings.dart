


import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/states/Pool.dart';

class MemberSettings extends StatelessWidget {

  final Pool pool;

  MemberSettings(this.pool);

  @override
  Widget build(BuildContext context) {

    List<UserModel> userList = [];
    
    pool.logList.members.forEach((key, value) {userList.add(value);});

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          child: Text('Members of ${pool.poolName}'),
          fit: BoxFit.scaleDown,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: userList.length,
        itemBuilder: /*1*/ (context, i) {
          return Row(
            children: <Widget>[
              Container(
                child: _provideAvatar(context, userList[i]),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),            
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(userList[i].name, style: TextStyle(fontSize: 20)),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(userList[i].role),
                    ),
                  ]
                ),
              ),
              Container(
                child: IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () => {} ,
                ),
                padding: EdgeInsets.only(right: 10),
              )
            ],
          );
        }
      ),
    );
  }

  Widget _provideAvatar(BuildContext context, UserModel _user){

    if (_user.photo == null){
      return CircleAvatar(
        backgroundColor: Colors.grey[100],
        //foregroundColor: Theme.of(context).accentColor,
        radius: 28,
        child: Text(_user.name[0].toUpperCase(), style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,))
      );
    }
    return CircleAvatar(
      backgroundImage: MemoryImage(_user.photo),
      radius: 28,
    );
  }





}