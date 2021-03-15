import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:petrolshare/models/UserModel.dart';

class NameAndIcon extends StatelessWidget {
  final Function logoutCallback;
  final UserModel user;

  NameAndIcon(this.user, this.logoutCallback, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          child: Hero(
            child: _provideAvatar(context, user),
            tag: "profilepic",
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _nameAndSubtext(),
          ),
        ),
        Container(
          child: IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => logoutCallback(context, user),
          ),
          padding: EdgeInsets.only(right: 10),
        )
      ],
    );
  }

  Widget _provideAvatar(BuildContext context, UserModel _user) {
    if (_user.photoBytes == null) {
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
      backgroundImage: MemoryImage(_user.photoBytes),
      radius: 28,
    );
  }

  List<Widget> _nameAndSubtext() {
    if (user.identifier != null)
      return <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(user.name, style: TextStyle(fontSize: 20)),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(user.identifier),
        )
      ];
    else
      return <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(user.name, style: TextStyle(fontSize: 20)),
        )
      ];
  }
}
