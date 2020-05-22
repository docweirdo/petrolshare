

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:petrolshare/models/UserModel.dart';

class DataService{

  final UserModel _user;
  final CloudFunctions cf = CloudFunctions(region: 'europe-west1');
    

  DataService(this._user);

  Firestore _firestore = Firestore.instance;
  
  Stream<UserModel>  updatedUserModel() {
    DocumentReference userRef = _firestore.collection('users').document(_user.uid);
    return userRef.snapshots().map((userDoc) {
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
  
  Future<void> renamePool(String poolname, String poolID) {

    DocumentReference poolRef = _firestore.collection('pools').document(poolID);

    return poolRef.updateData({'name': poolname});

  }

}