import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/states/Pool.dart';

class DataService {
  final CloudFunctions cf = CloudFunctions(region: 'europe-west1');

  static Firestore _firestore = Firestore.instance;

  /// Takes a [UserModel] and a [Pool] and listens to changes to the UserDoc.
  ///
  /// Returns a Stream of an updated UserModel using [getUserModel(String uid, String poolID)].
  static Stream<UserModel> updatedUserModel(UserModel user, {String poolID}) {
    DocumentReference userRef =
        _firestore.collection('users').document(user.uid);
    return userRef.snapshots().map((userDoc) {
      debugPrint("User Document Stream fired");
      if (!userDoc.exists) return user;
      return fromUserDoc(user.uid, userDoc, poolID: poolID);
    });
  }

  /// Retrieves the UserModel corresponding to an [UID].
  static Future<UserModel> getUserModel(String uid, {String poolID}) async {
    DocumentSnapshot userDoc = await _firestore.document('users/$uid').get();

    if (!userDoc.exists) return null;

    return fromUserDoc(uid, userDoc, poolID: poolID);
  }

  /// Takes a Firebase User Document converts it to a UserModel
  static UserModel fromUserDoc(String uid, DocumentSnapshot userDoc,
      {String poolID}) {
    if (!userDoc.exists) return null;

    Map<String, String> membership;
    String identifier =
        userDoc['identifier'] ?? userDoc['email'] ?? userDoc['phone'];

    if (userDoc['membership'] != null && userDoc['membership'].isNotEmpty)
      membership = Map.from(userDoc['membership']);

    return UserModel(uid, userDoc['name'], userDoc['photoURL'],
        role: poolID == null ? null : userDoc['membership.$poolID'],
        identifier: identifier,
        isAnonymous: identifier == null,
        membership: membership);
  }

  /// Streams a Map following changes of Membership or Members of Pool with ID [poolID].
  static Stream<Map<String, UserModel>> streamPoolMembers(String poolID) {
    DocumentReference poolRef = _firestore.collection('pools').document(poolID);

    return poolRef.snapshots().map((poolDoc) {
      debugPrint("Selected Pool Document Stream fired");

      if (!poolDoc.exists || poolDoc['members'] == null) {
        throw "Pool $poolID members field doesn't exist";
      }

      Map<String, UserModel> members = {};

      poolDoc['members'].forEach((uid, properties) {
        members[uid] = UserModel(
            uid, properties['name'], properties['photoURL'],
            role: properties['role']);
      });

      return members;
    });
  }

/*
  Future<String> createPool(String poolname) async {
    HttpsCallable callable = cf.getHttpsCallable(functionName: 'createPool');

    callable.timeout = const Duration(seconds: 30);

    try {
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{'poolname': poolname},
      );
      return result.data['poolID'];
    } on CloudFunctionsException catch (e) {
      print('caught firebase functions exception');
      print(e.code);
      print(e.message);
      print(e.details);
    } catch (e) {
      print('caught generic exception');
      print(e);
    }

    throw Exception('Something went wrong');
  }

  Future<void> renamePool(String poolname, Pool pool) {
    DocumentReference poolRef =
        _firestore.collection('pools').document(pool.pool);

    return poolRef
        .updateData({'name': poolname})
        .then((value) => pool.pools[pool.pool] = poolname)
        .then((value) => pool.notify());
  }

  Future<void> deletePool(Pool pool) async {
    HttpsCallable callable = cf.getHttpsCallable(functionName: 'deletePool');

    callable.timeout = const Duration(seconds: 30);

    try {
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{'poolID': pool.pool},
      );

      pool.pools.remove(pool.pool);

      pool.pool = null;

      pool.poolState = PoolState.retrieved;

      return null;
    } on CloudFunctionsException catch (e) {
      print('caught firebase functions exception');
      print(e.code);
      print(e.message);
      print(e.details);
    } catch (e) {
      print('caught generic exception');
      print(e);
    }

    throw Exception('Something went wrong');
  }

  Future<void> makeAdmin(String uid, String poolID) async {
    HttpsCallable callable = cf.getHttpsCallable(functionName: 'makeAdmin');

    callable.timeout = const Duration(seconds: 30);

    try {
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{'poolID': poolID, 'uid': uid},
      );
      return;
    } on CloudFunctionsException catch (e) {
      print('caught firebase functions exception');
      print(e.code);
      print(e.message);
      print(e.details);
    } catch (e) {
      print('caught generic exception');
      print(e);
    }

    throw Exception('Something went wrong');
  }

  Future<void> removeUserFromPool(String uid, Pool pool) async {
    HttpsCallable callable =
        cf.getHttpsCallable(functionName: 'removeUserFromPool');

    callable.timeout = const Duration(seconds: 30);

    try {
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{'poolID': pool.pool, 'uid': uid},
      );

      return;
    } on CloudFunctionsException catch (e) {
      print('caught firebase functions exception');
      print(e.code);
      print(e.message);
      print(e.details);
    } catch (e) {
      print('caught generic exception');
      print(e);
    }

    throw Exception('Something went wrong');
  }
  */
}
