import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/models/LogModel.dart';
import 'package:petrolshare/models/UserModel.dart';

class DataService {
  static final FirebaseFunctions cf =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Takes a [UserModel] and a [Pool] and listens to changes to the UserDoc.
  ///
  /// Returns a Stream of an updated UserModel using [getUserModel(String uid, String poolID)].
  static Stream<UserModel> streamUserModel(UserModel user, {String poolID}) {
    DocumentReference userRef = _firestore.collection('users').doc(user.uid);
    return userRef.snapshots().map((userDoc) {
      debugPrint("User Document Stream fired");
      if (!userDoc.exists) return user;
      return fromUserDoc(user.uid, userDoc, poolID: poolID);
    });
  }

  /// Retrieves the UserModel corresponding to an [UID].
  static Future<UserModel> getUserModel(String uid, {String poolID}) async {
    DocumentSnapshot userDoc = await _firestore.doc('users/$uid').get();

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
    DocumentReference poolRef = _firestore.collection('pools').doc(poolID);

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

  static Stream<List<dynamic>> streamLogEntries(poolID) {
    DocumentReference poolRef = _firestore.collection('pools').doc(poolID);

    Map<String, LogModel> addedOrModified = {};
    List<String> removed = [];

    return poolRef.collection('logs').snapshots().map((snap) {
      snap.docChanges.forEach((change) {
        debugPrint("Log Stream fired");

        DocumentSnapshot doc = change.doc;

        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            addedOrModified[change.doc.id] = LogModel.firebase(
                doc.id,
                doc['uid'],
                doc['roadmeter'],
                doc['price'],
                doc['amount'],
                doc['date'],
                doc['notes']);
            break;
          case DocumentChangeType.removed:
            removed.add(doc.id);
            break;
          default:
        }
      });
      return [addedOrModified, removed];
    });
  }

  static Future<void> addLog(LogModel log, String poolID) {
    return _firestore
        .collection('pools')
        .doc(poolID)
        .collection('logs')
        .add(log.toMap());
  }

// Wrote this function but might not need it at all lol
/*
  /// Gets List of possible Pools for a given [UserModel]
  static Future<Map<String, String>> fetchPoolSelection(UserModel user) async {
    DocumentSnapshot userDoc =
        await _firestore.doc('users/${user.uid}').get();
    Map<String, String> pools = {};

    if (!userDoc.exists) {
      throw "Userdoc with ID ${user.uid} doesn't exist";
    } else if (userDoc['membership'] == null) {
      throw "User with ID ${user.uid} has no membership field";
    } else if (userDoc['membership'].isEmpty) {
      return pools;
    }

    userDoc['membership'].forEach((key, value) => pools[key] = value);

    return pools;
  }

*/

  /// Checks whether Doc of given [poolID] is alright, returns role of [userID] in that pool.
  static Future<String> checkOutPool(String poolID, String userID) async {
    DocumentSnapshot poolSnap = await _firestore.doc('pools/$poolID').get();
    if (!poolSnap.exists) throw "Chosen pool $poolID doesn't exist";
    if ((poolSnap['members'] == null) ||
        (poolSnap['founder'] == null) ||
        (poolSnap['created'] == null) ||
        (poolSnap['name'] == null)) {
      throw "Pool $poolID is incomplete";
    }
    if (poolSnap['members.$userID'] == null)
      throw "User $userID not member of Pool document with ID $poolID";
    return poolSnap['members.$userID'];
  }

  static Future<String> createPool(String poolname) async {
    HttpsCallable callable = cf.httpsCallable('createPool');

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{'poolname': poolname},
    );
    return result.data['poolID'];
  }

  static Future<void> renamePool(String poolID, String poolname) {
    DocumentReference poolRef = _firestore.collection('pools').doc(poolID);

    return poolRef.update({'name': poolname});
  }

  static Future<void> deletePool(String poolID) async {
    HttpsCallable callable = cf.httpsCallable('deletePool');

    await callable.call(
      <String, dynamic>{'poolID': poolID},
    );
  }

  static Future<void> makeAdmin(String uid, String poolID) async {
    HttpsCallable callable = cf.httpsCallable('makeAdmin');

    await callable.call(
      <String, dynamic>{'poolID': poolID, 'uid': uid},
    );
  }

  static Future<void> removeMemberFromPool(String uid, String poolID) async {
    HttpsCallable callable = cf.httpsCallable('removeUserFromPool');

    await callable.call(
      <String, dynamic>{'poolID': poolID, 'uid': uid},
    );
  }
}
