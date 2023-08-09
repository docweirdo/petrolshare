import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/widgets/ProvideAvatar.dart';

class NameAndIcon extends StatelessWidget {
  final Function logoutCallback;
  final UserModel user;

  NameAndIcon(this.user, this.logoutCallback, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          child: Hero(
            child: ProvideAvatar(user),
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


  List<Widget> _nameAndSubtext() {
    if (user.identifier != null)
      return <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(user.name, style: TextStyle(fontSize: 20)),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(user.identifier ?? 'Anonymous'),
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
