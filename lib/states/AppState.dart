import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/services/data.dart';

enum PoolStatus { notstarted, nopools, retrieved, selected }

class AppState extends ChangeNotifier {
  PoolStatus poolStatus = PoolStatus.notstarted;
  String? selectedPool;
  String? selectedPoolRole; // Ugly but necessary because of overwriting stream / edit: what???
  Map<String, String> availablePools = {};

  late UserModel user;

  AppState(User user) {
    update(user);
  }

  /// Updates the [AppState] and contained [UserModel] when the
  /// Firebase User has changed.
  void update(User authUser) async {
    //print(authUser);

    UserModel? user = await DataService.getUserModel(authUser.uid, poolID: selectedPool);

    // In case a new user is created and the cloudfunction hasn't fired yet
    user ??= UserModel(
        authUser.uid,
        authUser.isAnonymous ? 'Anonymous' : (authUser.displayName ?? 'Anonymous'), // TODO: Not pretty, try to find cleaner solution
        authUser.photoURL,
        identifier: authUser.isAnonymous
            ? null
            : (authUser.email ?? authUser.phoneNumber),
        isAnonymous: authUser.isAnonymous,
        membership: {});

    availablePools = user.membership;
    poolStatus =
        availablePools.isEmpty ? PoolStatus.nopools : PoolStatus.retrieved;

    DataService.streamUserModel(user, poolID: selectedPool)
        .listen(onUpdatedUserModel);
  }

  // TODO: This function will need to decide which change warrants [notifyListeners()]
  void onUpdatedUserModel(UserModel updatedUser) async {
    debugPrint("AppState: onUpdatedUserModel() fired");

    user = updatedUser;
    availablePools = updatedUser.membership;

    if (user.uid != updatedUser.uid) {
      selectedPoolRole = null;
      selectedPool = null;
      poolStatus =
          availablePools.isEmpty ? PoolStatus.nopools : PoolStatus.retrieved;
    }

    if (availablePools[selectedPool] == null &&
        poolStatus == PoolStatus.selected) {
      // Pool might have gotten deleted in the meantime?
      selectedPool = availablePools.entries.first.value;
    }

    if (poolStatus == PoolStatus.selected) {
      user.roleString = selectedPoolRole;
    }

    debugPrint("AppState: onUpdatedUserModel() calls notifyListeners()");
    notifyListeners();
  }

  /// Sets the selected Pool to [poolID] if everything checks out.
  Future<String> setPool(String poolID) async {
    if (poolID == selectedPool) return "";
    if (user.membership[poolID] == null)
      throw "User ${user.uid} not member of Pool $poolID";

    List<dynamic> result = await DataService.checkOutPool(poolID, user.uid);

    String poolName = result[1];
    selectedPoolRole = result[0];

    user.roleString = selectedPoolRole;
    selectedPool = poolID;
    poolStatus = PoolStatus.selected;

    debugPrint("AppState: setPool() calls notifyListeners()");
    notifyListeners();

    return poolName;
  }

  /// Creates a new Pool of name [poolname] in the name of
  /// the current user and returns the new pools ID.
  Future<String> createPool(String poolname) async {
    if (user.isAnonymous) throw "User ${user.uid} is anonymous";
    if (availablePools.length > 4) throw "User ${user.uid} owns too many pools";
    if (poolname.length > 15)
      throw "Poolname \"$poolname\" longer than 15 chars.";

    //Presumably triggers UserDoc Stream, no further action?
    String newPoolID = await DataService.createPool(poolname);

    /*
    // Do this so user has to choose pool again after docChange stream fires
    selectedPool = null;
    poolStatus = PoolStatus.notstarted;
    */

    selectedPool = newPoolID;
    return newPoolID;
  }

  Future<void> deletePool(String poolID) async {
    // Presumably triggers UserDoc Stream, no further action?
    await DataService.deletePool(poolID);
  }
}
