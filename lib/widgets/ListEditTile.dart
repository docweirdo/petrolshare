
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListEditTile extends StatelessWidget{

  final Function editCallback;
  final String title;
  final String info;
  final Icon leadingIcon;
  final List<dynamic> args;

  ListEditTile({@required this.info, @required this.title, @required this.leadingIcon, @required this.editCallback, this.args = const []});

  @override
  Widget build(BuildContext context) {
    

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      leading: leadingIcon,
      trailing: Icon(Icons.edit),
      onTap: () {
        if (args.isNotEmpty){
          editCallback(context, args);
        }
        else editCallback(context);
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(info, style: TextStyle(color: Colors.grey, fontSize: 12)),
          FittedBox(
            child: Text(title, style: TextStyle(fontSize: 18)),
            fit: BoxFit.scaleDown,
          ),
        ]
      ),
    );
  }


}