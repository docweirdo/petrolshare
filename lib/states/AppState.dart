import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/services/data.dart';

enum PoolStatus { notstarted, nopools, retrieved, selected }

class AppState extends ChangeNotifier {
  PoolStatus poolStatus = PoolStatus.notstarted;
  String selectedPool;
  String selectedPoolRole; // Ugly but necessary because of overwriting stream
  Map<String, String> availablePools = {};

  UserModel _user;

  AppState(FirebaseUser firebaseUser) {
    update(firebaseUser);
  }

  /// Updates the [AppState] and contained [UserModel] when the
  /// Firebase User has changed.
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
      poolStatus = PoolStatus.notstarted;
      selectedPoolRole = null;
      selectedPool = null;
      poolStatus =
          availablePools.isEmpty ? PoolStatus.nopools : PoolStatus.retrieved;
    }

    _user = updatedUser;
    availablePools = updatedUser.membership;

    if (availablePools[selectedPool] == null &&
        poolStatus == PoolStatus.selected) {
      // Pool might have gotten deleted in the meantime?
      selectedPool = availablePools.entries.first.value;
    }

    if (poolStatus == PoolStatus.selected) {
      _user.roleString = selectedPoolRole;
    }

    notifyListeners();
  }

  /// Sets the selected Pool to [poolID] if everything checks out.
  Future<void> setPool(String poolID) async {
    if (_user.membership[poolID] == null)
      throw "User ${_user.uid} not member of Pool $poolID";
    selectedPoolRole = await DataService.checkOutPool(poolID, _user.uid);
    _user.roleString = selectedPoolRole;
    selectedPool = poolID;
    poolStatus = PoolStatus.selected;
    notifyListeners();
  }

  /// Creates a new Pool of name [poolname] in the name of
  /// the current user and returns the new pools ID.
  Future<String> createPool(String poolname) {
    if (_user.isAnonymous) throw "User ${_user.uid} is anonymous";
    if (availablePools.length > 4)
      throw "User ${_user.uid} owns too many pools";
    if (poolname.length > 15)
      throw "Poolname \"$poolname\" longer than 15 chars.";

    return DataService.createPool(poolname);
  }

  Future<void> deletePool(String poolID) async {
    // Presumably triggers UserDoc Stream, no further action?
    await DataService.deletePool(poolID);
  }
}
