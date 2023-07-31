import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/states/AppState.dart';
import 'package:petrolshare/states/PoolState.dart';
import 'package:petrolshare/widgets/ProvideAvatar.dart';
import 'package:provider/provider.dart';

class MemberSettings extends StatelessWidget {
  MemberSettings();

  @override
  Widget build(BuildContext context) {
    AppState appState = Provider.of<AppState>(context);
    PoolState poolState = Provider.of<PoolState>(context);

    List<UserModel> userList = [];

    poolState.members.forEach((key, value) {
      userList.add(value);
    });

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          child: Text('Members of ${poolState.name}'),
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
                  child: ProvideAvatar(userList[i]),
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
                          child: Text(userList[i].roleString[0].toUpperCase() +
                              userList[i].roleString.substring(1)),
                        ),
                      ]),
                ),
                Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Visibility(
                    visible: (userList[i].uid != appState.user.uid),
                    child: PopupMenuButton<MemberAction>(
                      child: Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == MemberAction.Admin)
                          _handleAdmin(userList[i], poolState);
                        if (value == MemberAction.Delete)
                          _handleRemoval(userList[i], poolState);
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


  void _handleAdmin(UserModel user, PoolState poolState) async {
    try {
      poolState.makeAdmin(user);
    } catch (e) {
      SnackBar(content: Text('Something went wrong.'));
    }
  }

  void _handleRemoval(UserModel user, PoolState poolState) async {
    try {
      poolState.removeMember(user.uid);
    } catch (e) {
      SnackBar(content: Text('Something went wrong.'));
    }
  }
}

enum MemberAction { Admin, Delete }
