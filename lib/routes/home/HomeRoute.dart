import 'dart:async';
import 'package:petrolshare/models/LogModel.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/widgets/open_container_push_future.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/routes/home/NewEntryRoute.dart';
import 'package:petrolshare/states/Pool.dart';
import 'package:petrolshare/widgets/PoolWrapper.dart';
import 'package:provider/provider.dart';
import 'package:spiffy_button/spiffy_button.dart';



final duration = const Duration(milliseconds: 250);


class HomeRoute extends StatefulWidget {
  HomeRoute({Key key}) : super(key: key);

  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> with RouteAware{
  int _selectedIndex = 0;
  bool scrolling = false;
  bool _fabVisible = true;
  Pool _pool;

  final _fabKey = GlobalKey<SpiffyButtonState>();
  UserModel _user;
  
  @override
  void initState() {
    super.initState();
    animate();
  }

  void animate() async {
    final pause = const Duration(milliseconds: 100);

    if(_pool != null && _pool.poolsRetrieved == 2) {
      await Future.delayed(pause);
      _fabKey.currentState.pose = SpiffyButtonPose.shownIconAndLabel;
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _fabVisible = _selectedIndex == 0;
      if (index == 0){
        animate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    _pool = Provider.of<Pool>(context);
    _user = _pool.user;

    print("built homeRoute");

    return Scaffold(
      //backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: FittedBox(
          child: Text(_selectedIndex == 2 ? 'Petrolshare' : (_pool?.poolName ?? 'Petrolshare')),
          fit: BoxFit.scaleDown,
        ),
        centerTitle: true,
        elevation: 1.0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: NotificationListener<ScrollEndNotification>(
        onNotification: (end) {
          if (end.metrics.pixels == 0.0) {
            _fabKey.currentState?.pose = SpiffyButtonPose.shownIconAndLabel;
            scrolling = false;
          }
          return true;
        },
        child: NotificationListener<ScrollStartNotification>(
          onNotification: (start) {
            _fabKey.currentState?.pose = SpiffyButtonPose.shownIcon;
            scrolling = true;
            return true;
          },
          child: PoolWrapper(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            title: Text('Logs'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            title: Text('Stats'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            title: Text('Manage'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).accentColor,
        onTap: _onItemTapped,
      ),
      floatingActionButton: Visibility(
        child: OpenContainerPushFuture(
          openBuilder: (BuildContext context, VoidCallback _) {
            return NewEntryRoute();
          },
          closedElevation: 6.0,
          closedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          closedColor: Theme.of(context).colorScheme.secondary,
          closedBuilder: (BuildContext context, Function openContainer) {
            return SpiffyButton(
              key: _fabKey,
              icon: Icon(Icons.local_gas_station),
              label: Text("Add"),
              initialPose: SpiffyButtonPose.shownIcon,
              onTouchDown: () async{
                dynamic result = await openContainer();
                if (result != null){
                  _pool.logList.add(
                    LogModel(
                      ValueKey(result['roadmeter']).toString(), 
                      _user.uid, 
                      result['roadmeter'], 
                      result['price'], 
                      result['amount'], 
                      result['date'], 
                      _user.name,
                      result['notes']
                    )
                  );
                  Scaffold.of(context).showSnackBar(SnackBar(content: Text('Entry added')));
                }
              }
            );
          }
        ),
        visible: (_fabVisible && (_pool.poolsRetrieved == 2)),
      )
    );
  }


}