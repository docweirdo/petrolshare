import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/services/data.dart';
import 'package:petrolshare/states/Pool.dart';

enum PoolState { notstarted, nopools, retrieved, selected }

class AppState extends ChangeNotifier {
  PoolState poolState = PoolState.notstarted;
  Pool selectedPool;
  Map<String, String> availablePools;

  UserModel _user;

  /// Updates the [AppState] and containing [UserModel] when the Firebase User has changed.
  void update(FirebaseUser authUser) async {
    UserModel user = await DataService.getUserModel(authUser.uid, selectedPool);

    if (user == null) {
      // Incase a new user is created and the cloudfunction hasn't fired yet
      _user = UserModel(
          authUser.uid,
          authUser.isAnonymous ? 'Anonymous' : authUser.displayName,
          authUser.photoUrl,
          identifier: authUser.isAnonymous
              ? null
              : (authUser.email ?? authUser.phoneNumber),
          isAnonymous: authUser.isAnonymous);
    } else
      _user = user;

    DataService.updatedUserModel(_user, selectedPool)
        .listen((UserModel updatedUser) async {
      if (_user.photoURL != updatedUser.photoURL) {
        _user.photoURL = updatedUser.photoURL;
        await _user.loadPhotoFromURL(updatedUser.photoURL);
      }

      _user = updatedUser;

      notifyListeners();
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
}
