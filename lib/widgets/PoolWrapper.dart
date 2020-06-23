

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:petrolshare/routes/home/tabs/ManageStrippedTab.dart';
import 'package:petrolshare/routes/home/tabs/NoPoolTab.dart';
import 'package:petrolshare/states/LogList.dart';
import 'package:petrolshare/states/Pool.dart';
import 'package:petrolshare/widgets/PoolList.dart';
import 'package:provider/provider.dart';
import 'package:petrolshare/routes/home/tabs/LogsTab.dart';
import 'package:petrolshare/routes/home/tabs/StatsTab.dart';
import 'package:petrolshare/routes/home/tabs/ManageTab.dart'; 

class PoolWrapper extends StatelessWidget{

  final int _selectedIndex;

  final _widgetOptions = [
    LogsTab(),
    StatsTab(),
    ManageTab(),
  ];

  final _fakeWidgetOptions = [
    Center(child: CircularProgressIndicator()),
    NoPoolTab(), //Screen for new pool and joining
    ManageStrippedTab(),
  ];

  PoolWrapper(this._selectedIndex);

  @override
  Widget build(BuildContext context){

    print("built PoolWrapper");

    Pool _pool = Provider.of<Pool>(context);

    if (_pool.poolState == PoolState.notstarted){
      Future<Map<String, String>> pools = _pool.fetchPoolSelection();
      pools.then((value) => poolSelection(context, value))
      .then((value) {if (value != null) _pool.setPool(value);});
    }
    return _figureOutTab(_pool);
  }

  Widget _figureOutTab(Pool _pool){

    if (_selectedIndex == 2) 
    return (_pool.poolState == PoolState.selected ? _widgetOptions[_selectedIndex] : _fakeWidgetOptions[_selectedIndex]);
    else {

      Widget childWidget;

      switch (_pool.poolState) {
        case PoolState.notstarted:
          childWidget = _fakeWidgetOptions[0];
          break;
        case PoolState.nopools:
          childWidget = _fakeWidgetOptions[1];
          break;
        case PoolState.retrieved:
          childWidget = _fakeWidgetOptions[1];
          break;
        case PoolState.selected:
          childWidget = _widgetOptions[_selectedIndex];
          break;
      }

      return ChangeNotifierProvider<LogList>.value(
        value: _pool.logList,
        child: childWidget,
      );
    }

  }


  Future<String> poolSelection(BuildContext context, Map<String, String> pools){
    
    if (pools.isEmpty) return null;

    if (pools.length == 1) return Future.value(pools.keys.toList()[0]);
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('Choose a pool'),
          content: PoolList(pools),
        );
      }
    );
  }


}