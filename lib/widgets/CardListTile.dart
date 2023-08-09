import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:petrolshare/models/LogModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/states/PoolState.dart';
import 'package:petrolshare/widgets/ProvideAvatar.dart';
import 'package:provider/provider.dart';

class CardListTile extends StatelessWidget {
  final LogModel logModel;

  CardListTile({required this.logModel});

  @override
  Widget build(BuildContext context) {
    ValueKey key = ValueKey(logModel.id);

    return Container(
        margin: EdgeInsets.all(4),
        color: Colors.transparent,
        child: Slidable(
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: <Widget>[
              SlidableAction(
                label: 'Delete',
                backgroundColor: Colors.red,
                icon: Icons.delete,
                onPressed: (context) => ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Archive'))),
              ),
              SlidableAction(
                label: 'Edit',
                backgroundColor: Colors.blue,
                icon: Icons.edit,
                onPressed: (context) => ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Edit'))),
              ),
            ],
            ),
            child: Card(
              key: key,
              elevation: 0,
              margin: EdgeInsets.all(0),
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.4),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                constraints: BoxConstraints(maxHeight: 300),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor),
                        padding: EdgeInsets.fromLTRB(
                            15, 15, 0, 15), //padding to the right individually
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(right: 20),
                                    child: _provideAvatar(
                                        context, logModel),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text(
                                              _formatDate(logModel.date),
                                              style: TextStyle(fontSize: 27)),
                                        ),
                                        Text(
                                          logModel.name!,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Padding(
                              padding: EdgeInsets.only(right: 5.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    //Container(),
                                    Expanded(
                                      child: Wrap(
                                        spacing: 8.0,
                                        runSpacing: -10.0,
                                        children: <Widget>[
                                          Chip(
                                            avatar: Icon(Icons.euro_symbol),
                                            label: Text(_formatNumbers(
                                                logModel.price)),
                                            labelPadding:
                                                EdgeInsets.only(right: 5),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 2),
                                          ),
                                          Chip(
                                            avatar:
                                                Icon(Icons.local_gas_station),
                                            label: Text(_formatNumbers(
                                                logModel.amount)),
                                            labelPadding:
                                                EdgeInsets.only(right: 5),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 2),
                                          ),
                                          Chip(
                                            avatar:
                                                Icon(Icons.slow_motion_video),
                                            label: Text(_formatNumbers(
                                                logModel.roadmeter)),
                                            labelPadding:
                                                EdgeInsets.only(right: 5),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                            ),
                            Visibility(
                              visible: logModel.notes != null &&
                                  logModel.notes!.isNotEmpty,
                              child: Divider(),
                            ),
                            Visibility(
                                visible: logModel.notes != null &&
                                    logModel.notes!.isNotEmpty,
                                child: Text(logModel.notes ?? ''))
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(_formatNumbers(logModel.price),
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text("Euro", style: TextStyle(fontSize: 14)),
                          ]),
                    ),
                  ],
                ),
              ),
            )));
  }

  Widget _provideAvatar(BuildContext context, LogModel logModel) {
    UserModel? user =
        Provider.of<PoolState>(context, listen: false).members[logModel.uid];

    return ProvideAvatar(user!);
  }

  String _formatDate(DateTime date) {
    var formatter = new DateFormat('dd.MM.yyyy');
    return formatter.format(date);
  }

  String _formatNumbers(var roadmeter) {
    var formatter = new NumberFormat('##,###,###.#', "de_DE");
    return formatter.format(roadmeter);
  }


}
