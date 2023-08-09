import 'package:flutter/material.dart';
import 'package:petrolshare/routes/home/tabs/ManageStrippedTab.dart';
import 'package:petrolshare/routes/home/tabs/NoPoolTab.dart';
import 'package:petrolshare/states/AppState.dart';
import 'package:provider/provider.dart';
import 'package:petrolshare/routes/home/tabs/LogsTab.dart';
import 'package:petrolshare/routes/home/tabs/StatsTab.dart';
import 'package:petrolshare/routes/home/tabs/ManageTab.dart';

import '../helpers/poolSelectionDialog.dart';

class PoolWrapper extends StatelessWidget {
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
  Widget build(BuildContext context) {
    debugPrint("PoolWrapper: built");

    AppState appState = Provider.of<AppState>(context);

    if (appState.poolStatus == PoolStatus.retrieved) {
      Future.delayed(
          Duration.zero,
          () => poolSelection(context, appState.availablePools).then((value) {
                if (value != null) appState.setPool(value);
              }));

      debugPrint("PoolWrapper: AppState.poolStatus: ${appState.poolStatus}");
    }
    return _figureOutTab(appState);
  }

  Widget _figureOutTab(AppState appState) {
    if (_selectedIndex == 2)
      return (appState.poolStatus == PoolStatus.selected
          ? _widgetOptions[_selectedIndex]
          : _fakeWidgetOptions[_selectedIndex]);
    else {
      Widget childWidget;

      switch (appState.poolStatus) {
        case PoolStatus.notstarted:
          childWidget = _fakeWidgetOptions[0];
          break;
        case PoolStatus.nopools:
          childWidget = _fakeWidgetOptions[1];
          break;
        case PoolStatus.retrieved:
          childWidget = _fakeWidgetOptions[1];
          break;
        case PoolStatus.selected:
          childWidget = _widgetOptions[_selectedIndex];
          break;
      }

      return childWidget;
    }
  }

}