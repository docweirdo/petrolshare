

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petrolshare/models/UserModel.dart';

class DataService{

  final UserModel _user;

  DataService(this._user);

  Firestore _firestore = Firestore.instance;
  
  Stream<UserModel>  updatedUserModel() {
    DocumentReference userRef = _firestore.collection('users').document(_user.uid);
    return userRef.snapshots().map((userDoc) {
      if (!userDoc.exists) return _user;
      else return UserModel(_user.uid, userDoc['name'], userDoc['photoURL'], true, _user.role, _user.identifier);
    });
  }

}