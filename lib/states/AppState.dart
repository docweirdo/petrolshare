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
}
