import 'package:flutter/widgets.dart';
import 'package:petrolshare/models/LogModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/states/LogList.dart';
import 'package:provider/provider.dart';

class CardListTile extends StatelessWidget{

  final LogModel logModel;

  CardListTile({@required this.logModel});

  @override
  Widget build(BuildContext context){
    return Card(
      elevation: 0,
      key: ValueKey(logModel.id),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.grey.withOpacity(0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(right: 20),
                        child: _provideAvatar(context, logModel),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          Text(_formatDate(logModel.date), style: TextStyle(fontSize: 27)),
                          Text(logModel.name, style: TextStyle(fontSize: 14),),
                        ],
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: -10.0,
                        children: <Widget>[
                          Chip(
                            avatar: Icon(Icons.euro_symbol),
                            label: Text(_formatNumbers(logModel.price)),
                            labelPadding: EdgeInsets.only(right: 5),
                            padding: EdgeInsets.symmetric(horizontal: 2),
                          ),
                          Chip(
                            avatar: Icon(Icons.invert_colors),
                            label: Text(_formatNumbers(logModel.amount)),
                            labelPadding: EdgeInsets.only(right: 5),
                            padding: EdgeInsets.symmetric(horizontal: 2),
                          ),
                          Chip(
                            avatar: Icon(Icons.slow_motion_video),
                            label: Text(_formatNumbers(logModel.roadmeter)),
                            labelPadding: EdgeInsets.only(right: 5),
                            padding: EdgeInsets.symmetric(horizontal: 2),
                          ),
                        ],
                      )
                    ]
                  ),
                  Divider(),
                  Visibility(
                    visible: logModel.notes != null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.ideographic,
                      children: <Widget>[
                        Text("Note: ", style: TextStyle(fontSize: 18)),
                        Text(logModel.notes ?? '')
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                decoration: new BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(_formatNumbers(logModel.price), style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,)),
                    Text("Euro", style: TextStyle(fontSize: 14)),
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _provideAvatar(BuildContext context, LogModel logModel){
    
    UserModel _user = Provider.of<LogList>(context, listen: false).members[logModel.uid];

    if (_user.photo == null){
      return CircleAvatar(
        backgroundColor: Colors.grey[100],
        //foregroundColor: Theme.of(context).accentColor,
        radius: 24,
        child: Text(logModel.name[0].toUpperCase(), style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,))
      );
    }
    return CircleAvatar(
      backgroundImage: MemoryImage(_user.photo),
      radius: 24,
    );
  }

  String _formatDate(DateTime date){
    var formatter = new DateFormat('dd.MM.yyyy');
    return formatter.format(date);
  }

  String _formatNumbers(var roadmeter){
    var formatter = new NumberFormat('##,###,###.#', "de_DE");
    return formatter.format(roadmeter);
  }

}