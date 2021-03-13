import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/services/data.dart';
import 'package:petrolshare/states/Pool.dart';

enum PoolStatus { notstarted, nopools, retrieved, selected }

class AppState extends ChangeNotifier {
  PoolStatus poolState = PoolStatus.notstarted;
  String selectedPool;
  Map<String, String> availablePools;

  UserModel _user;

  AppState(FirebaseUser firebaseUser) {
    update(firebaseUser);
  }

  /// Updates the [AppState] and contained [UserModel] when the Firebase User has changed.
  void update(FirebaseUser authUser) async {
    UserModel user =
        await DataService.getUserModel(authUser.uid, poolID: selectedPool);

    // Incase a new user is created and the cloudfunction hasn't fired yet
    user ??= UserModel(
        authUser.uid,
        authUser.isAnonymous ? 'Anonymous' : authUser.displayName,
        authUser.photoUrl,
        identifier: authUser.isAnonymous
            ? null
            : (authUser.email ?? authUser.phoneNumber),
        isAnonymous: authUser.isAnonymous);

    DataService.streamUserModel(user, poolID: selectedPool)
        .listen(onUpdatedUserModel);
  }

  // TODO: This function will need to decide which change warrants [notifyListeners()]
  void onUpdatedUserModel(UserModel updatedUser) async {
    if (_user.uid != updatedUser.uid) {
      poolState = PoolStatus.notstarted;
      selectedPool = null;
      availablePools = updatedUser.membership;
      poolState =
          availablePools.isEmpty ? PoolStatus.nopools : PoolStatus.retrieved;
    }

    _user = updatedUser;

    notifyListeners();
  }

  /// Sets the selected Pool to [poolID] if everything checks out.
  Future<void> setPool(String poolID) async {
    if (_user.membership[poolID] == null)
      throw "User ${_user.uid} not member of Pool $poolID";
    _user.roleString = await DataService.checkOutPool(poolID, _user.uid);
    selectedPool = poolID;
    poolState = PoolStatus.selected;
    notifyListeners();
  }
}
