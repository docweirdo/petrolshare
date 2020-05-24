
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListEditTile extends StatelessWidget{

  final Function editCallback;
  final String title;
  final String info;
  final Icon leadingIcon;

  ListEditTile({@required this.info, @required this.title, @required this.leadingIcon, @required this.editCallback});

  @override
  Widget build(BuildContext context) {
    

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      leading: leadingIcon,
      trailing: Icon(Icons.edit),
      onTap: editCallback,
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