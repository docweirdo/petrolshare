

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/states/Pool.dart';

class DataService{

  final UserModel _user;
  final CloudFunctions cf = CloudFunctions(region: 'europe-west1');
    

  DataService(this._user);

  Firestore _firestore = Firestore.instance;
  
  Stream<UserModel>  updatedUserModel() {
    DocumentReference userRef = _firestore.collection('users').document(_user.uid);
    return userRef.snapshots().map((userDoc) {
      print("User infos Changed");
      if (!userDoc.exists) return _user;
      else return UserModel(_user.uid, userDoc['name'], userDoc['photoURL'], true, _user.role, _user.identifier);
    });
  }

  Future<String> createPool(String poolname) async{
   
    HttpsCallable callable = cf.getHttpsCallable(functionName: 'createPool');
   
    callable.timeout = const Duration(seconds: 30);
    

    try {
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          'poolname': poolname
        },
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

    DocumentReference poolRef = _firestore.collection('pools').document(pool.pool);

    return poolRef.updateData({'name': poolname}).then((value) => pool.pools[pool.pool] = poolname).then((value) => pool.notify());

  }

  Future<void> deletePool(Pool pool) async{
  
    HttpsCallable callable = cf.getHttpsCallable(functionName: 'deletePool');
   
    callable.timeout = const Duration(seconds: 30);
    

    try {
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          'poolID': pool.pool
        },
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

  Future<void> makeAdmin(String uid, String poolID) async{
   
    HttpsCallable callable = cf.getHttpsCallable(functionName: 'makeAdmin');
   
    callable.timeout = const Duration(seconds: 30);
    

    try {
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          'poolID': poolID,
          'uid': uid
        },
      );
      return ;

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

}