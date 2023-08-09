
import 'package:petrolshare/models/LogModel.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/states/AppState.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/routes/home/NewEntryRoute.dart';
import 'package:petrolshare/states/PoolState.dart';
import 'package:petrolshare/widgets/PoolWrapper.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';

final duration = const Duration(milliseconds: 250);

class HomeRoute extends StatefulWidget {
  HomeRoute({super.key});

  @override
  _HomeRouteState createState() => _HomeRouteState();
}

// TODO: Are AppState, PoolState and Usermodel really needed outside the build function?
class _HomeRouteState extends State<HomeRoute> with RouteAware {
  int _selectedIndex = 0;
  bool scrolling = false;
  bool _fabVisible = true;
  PoolState? poolState;

  AppState? appState;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    // animate();
  }

  // void animate() async {
  //   final pause = const Duration(milliseconds: 100);

  //   if (appState.poolStatus == PoolStatus.selected) {
  //     // TODO: Find better way to position PoolStatus than in AppState
  //     await Future.delayed(pause);
  //     _fabKey.currentState.pose = SpiffyButtonPose.shownIconAndLabel;
  //   }
  // }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _fabVisible = _selectedIndex == 0;
      // if (index == 0) {
      //   animate();
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    poolState = Provider.of<PoolState>(context);
    user = appState?.user;

    debugPrint("HomeRoute: built");

    return Scaffold(
        //backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: FittedBox(
            child: Text(_selectedIndex == 2
                ? 'Petrolshare'
                : (poolState?.name ?? 'Petrolshare')),
            fit: BoxFit.scaleDown,
          ),
          centerTitle: true,
          elevation: 1.0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: PoolWrapper(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Logs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle),
              label: 'Manage',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          onTap: _onItemTapped,
        ),
        floatingActionButton: Visibility(
          child: OpenContainer(
        openBuilder: (BuildContext context, VoidCallback _) {
          return NewEntryRoute();
        },
        closedElevation: 6.0,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        closedColor: Theme.of(context).colorScheme.secondary,
        closedBuilder: (BuildContext context, VoidCallback openContainer) {
          return InkWell(
            child: SizedBox(
              height: 15,
              width: 15,
              child: Center(
                child: Icon(
                  Icons.local_gas_station,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
            onTapDown: (_) => openContainer()
          );},
          onClosed: (Map<String, dynamic>? result) {
                      if (result != null) {
                        poolState?.addLog(LogModel(
                            ValueKey(result['roadmeter']).toString(),
                            user!.uid,
                            result['roadmeter'],
                            result['price'],
                            result['amount'],
                            result['date'],
                            user!.name,
                            result['notes']));
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Entry added')));
                      }
          }
      ),
          visible:
              (_fabVisible && (appState?.poolStatus == PoolStatus.selected)),
        ));
  }
}
