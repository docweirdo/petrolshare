import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/services/data_old.dart';
import 'package:petrolshare/states/LogList.dart';

enum PoolState { notstarted, nopools, retrieved, selected }

class Pool extends ChangeNotifier {
  DataService data;
  UserModel user;
  Firestore _firebase = Firestore.instance;
  LogList logList;
  Map<String, String> pools;
  String pool;
  PoolState poolState = PoolState.notstarted;

  String get poolName => pools == null ? null : pools[pool];

  Pool(this.user) {
    data = DataService(user);
    data.updatedUserModel().listen((updatedUser) async {
      bool changed = false;

      if (user.name != updatedUser.name) {
        changed = true;
        user.name = updatedUser.name;
      }
      if (user.photoURL != updatedUser.photoURL) {
        await user.loadPhotoFromURL(updatedUser.photoURL);
        changed = true;
      }

      if (changed) notifyListeners();
    });
  }

  //get List of possible Pools
  Future<Map<String, String>> fetchPoolSelection() async {
    DocumentSnapshot userDoc = await _getUserInfo();
    pools = {};
    if (!userDoc.exists) {
      poolState = PoolState.nopools;
      notifyListeners();
      return pools;
    }
    if (userDoc['membership'] == null || userDoc['membership'].isEmpty) {
      poolState = PoolState.nopools;
      notifyListeners();
      return pools;
    }
    userDoc['membership'].forEach((key, value) => pools[key] = value);
    poolState = pools.isEmpty ? PoolState.nopools : PoolState.retrieved;
    return pools;
  }

  notify() => notifyListeners();

  //choose Pool
  Future<void> setPool(String poolID) async {
    DocumentSnapshot poolSnap = await _firebase.document('pools/$poolID').get();
    if (!poolSnap.exists) throw "Chosen pool $poolID doesn't exist";
    if ((poolSnap['members'] == null) ||
        (poolSnap['founder'] == null) ||
        (poolSnap['created'] == null) ||
        (poolSnap['name'] == null)) {
      throw "Pool $poolID.documentID is incomplete";
    }
    pool = poolID;
    logList = LogList(_firebase.document('pools/$poolID'));
    await logList.fetchPoolMembers();
    user.role = logList.members[user.uid]
        .role; //Set Rule of the global UserModel depending on Pool
    poolState = PoolState.selected;
    notifyListeners();
    logList
        .refreshLogs(); //maybe switch aroung the last two? is there a difference?
  }
}
