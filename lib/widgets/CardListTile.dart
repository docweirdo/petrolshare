import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:petrolshare/models/LogModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/states/PoolState.dart';
import 'package:provider/provider.dart';

class CardListTile extends StatefulWidget {
  final LogModel logModel;

  CardListTile({@required this.logModel});

  @override
  _CardListTileState createState() => _CardListTileState();
}

class _CardListTileState extends State<CardListTile> {
  Color backgroundColor;
  SlidableController slidableController;

  @override
  void initState() {
    super.initState();
    backgroundColor = Colors.transparent;
    slidableController = SlidableController(
        onSlideAnimationChanged: handleSlideAnimationChanged,
        onSlideIsOpenChanged: handleSlideIsOpenChanged);
  }

  @override
  Widget build(BuildContext context) {
    ValueKey key = ValueKey(widget.logModel.id);

    return Container(
        margin: EdgeInsets.all(4),
        color: backgroundColor,
        child: Slidable(
            actionPane: SlidableBehindActionPane(),
            showAllActionsThreshold: 0.99,
            fastThreshold: 1.0,
            controller: slidableController,
            actionExtentRatio: 0.25,
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Archive'))),
              ),
              IconSlideAction(
                caption: 'Edit',
                color: Colors.blue,
                icon: Icons.edit,
                onTap: () => Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Share'))),
              ),
            ],
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
                                        context, widget.logModel),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text(
                                              _formatDate(widget.logModel.date),
                                              style: TextStyle(fontSize: 27)),
                                        ),
                                        Text(
                                          widget.logModel.name,
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
                                                widget.logModel.price)),
                                            labelPadding:
                                                EdgeInsets.only(right: 5),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 2),
                                          ),
                                          Chip(
                                            avatar:
                                                Icon(Icons.local_gas_station),
                                            label: Text(_formatNumbers(
                                                widget.logModel.amount)),
                                            labelPadding:
                                                EdgeInsets.only(right: 5),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 2),
                                          ),
                                          Chip(
                                            avatar:
                                                Icon(Icons.slow_motion_video),
                                            label: Text(_formatNumbers(
                                                widget.logModel.roadmeter)),
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
                              visible: widget.logModel.notes != null &&
                                  widget.logModel.notes != '',
                              child: Divider(),
                            ),
                            Visibility(
                                visible: widget.logModel.notes != null &&
                                    widget.logModel.notes != '',
                                child: Text(widget.logModel.notes ?? ''))
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
                            Text(_formatNumbers(widget.logModel.price),
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
    UserModel user =
        Provider.of<PoolState>(context, listen: false).members[logModel.uid];

    if (user.photoBytes == null) {
      return CircleAvatar(
          backgroundColor: Colors.grey[100],
          //foregroundColor: Theme.of(context).accentColor,
          radius: 24,
          child: Text(logModel.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              )));
    }
    return CircleAvatar(
      backgroundImage: MemoryImage(user.photoBytes),
      radius: 24,
    );
  }

  String _formatDate(DateTime date) {
    var formatter = new DateFormat('dd.MM.yyyy');
    return formatter.format(date);
  }

  String _formatNumbers(var roadmeter) {
    var formatter = new NumberFormat('##,###,###.#', "de_DE");
    return formatter.format(roadmeter);
  }

  void handleSlideAnimationChanged(Animation<double> animation) {
    debugPrint("CardListTile: Slider animation status: ${animation?.value}");
    if ((animation?.value ?? 0) < 0.05)
      setState(() => backgroundColor = Colors.transparent);
  }

  void handleSlideIsOpenChanged(bool open) {
    debugPrint("CardListTile: Slider open: $open");
    if (open) setState(() => backgroundColor = Colors.red);
  }
}
