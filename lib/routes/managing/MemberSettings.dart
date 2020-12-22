import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/states/Pool.dart';
import 'package:provider/provider.dart';

class MemberSettings extends StatelessWidget {
  MemberSettings();

  @override
  Widget build(BuildContext context) {
    Pool pool = Provider.of<Pool>(context);

    List<UserModel> userList = [];

    pool.logList.members.forEach((key, value) {
      userList.add(value);
    });

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
                          child: Text(userList[i].name,
                              style: TextStyle(fontSize: 20)),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(userList[i].role[0].toUpperCase() +
                              userList[i].role.substring(1)),
                        ),
                      ]),
                ),
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Visibility(
                    visible: (userList[i].uid != pool.user.uid),
                    child: PopupMenuButton<MemberAction>(
                      child: Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == MemberAction.Admin)
                          _handleAdmin(userList[i].uid, pool);
                        if (value == MemberAction.Delete)
                          _handleRemoval(userList[i].uid, pool);
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<MemberAction>>[
                        const PopupMenuItem<MemberAction>(
                          value: MemberAction.Admin,
                          child: Text('Make admin'),
                        ),
                        const PopupMenuItem<MemberAction>(
                          value: MemberAction.Delete,
                          child: Text('Remove'),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  Widget _provideAvatar(BuildContext context, UserModel _user) {
    if (_user.photo == null) {
      return CircleAvatar(
          backgroundColor: Colors.grey[100],
          //foregroundColor: Theme.of(context).accentColor,
          radius: 28,
          child: Text(_user.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              )));
    }
    return CircleAvatar(
      backgroundImage: MemoryImage(_user.photo),
      radius: 28,
    );
  }

  void _handleAdmin(String uid, Pool pool) async {
    try {
      await pool.data.makeAdmin(uid, pool.pool);
    } catch (e) {
      SnackBar(content: Text('Something went wrong.'));
    }
  }

  void _handleRemoval(String uid, Pool pool) async {
    try {
      await pool.data.removeUserFromPool(uid, pool);
    } catch (e) {
      SnackBar(content: Text('Something went wrong.'));
    }
  }
}

enum MemberAction { Admin, Delete }
