import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/models/LogModel.dart';
import 'package:petrolshare/states/PoolState.dart';
import 'package:petrolshare/widgets/CardListTile.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:provider/provider.dart';

class LogsTab extends StatelessWidget {
  LogsTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PoolState>(builder: (context, poolState, _) {
      if (poolState.logs == null)
        return Container();
      else if (poolState.logState == LogState.retrieved)
        return _buildLogList(context, poolState);
      else
        return Center(child: CircularProgressIndicator());
      //TODO: Needs no logs screen
    });
  }

  Widget _buildLogList(BuildContext context, PoolState poolState) {
    UnmodifiableListView<LogModel> loglistEntrys = poolState.logs;

    return RefreshIndicator(
        onRefresh: () => Future.delayed(Duration(
            milliseconds: 500)), // TODO: Maybe decide what to do here :D
        child: ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: loglistEntrys.length,
            itemBuilder: /*1*/ (context, i) {
              return CardListTile(
                logModel: loglistEntrys[i],
              );
            }));
  }
}

/*

class _LogsTabState extends State<LogsTab>{

  Future<QuerySnapshot> logFuture;
  Widget logFutureBuilderWidget;

  @override
  void initState(){
    super.initState();
    logFuture = Firestore.instance.collection('pools/F6KTd3LRUVXU1BH589yg/logs').getDocuments();
    logFutureBuilderWidget = _createLogFutureBuilderWidget(context, logFuture);
  }
  

  Widget _buildLogList(BuildContext context, QuerySnapshot snapshot) {

    List<LogClass> logs = snapshot.documents.map( (doc) => 
      LogClass(doc.documentID, doc['user'], doc['roadmeter'], doc['price'], doc['amount'], doc['date'])
    ).toList();

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: snapshot.documents.length,
        itemBuilder: /*1*/ (context, i) {
          return CardListTile(logEntry: logs[i]);
        })
    );
  }

  
  @override
  Widget build(BuildContext context) => logFutureBuilderWidget;

  Widget _createLogFutureBuilderWidget(BuildContext context, Future<QuerySnapshot> logFuture){
    return FutureBuilder(
      future: logFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        return _buildLogList(context, snapshot.data);
      });
  }


  Future<void> _handleRefresh() async{

    Future<QuerySnapshot> firebaseFuture = Firestore.instance.collection('pools/F6KTd3LRUVXU1BH589yg/logs').getDocuments();
    
    return firebaseFuture.then((value) {
      setState(() => logFutureBuilderWidget = _createLogFutureBuilderWidget(context, firebaseFuture)); 
    });
  }


}
*/
