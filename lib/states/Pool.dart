import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/states/LogList.dart';

class Pool extends ChangeNotifier{

  UserModel user;
  Firestore _firebase = Firestore.instance;
  LogList logList;
  Map<String, String> pools;
  String pool;
  int poolsRetrieved = 0; //0-notstarted 1-nopools 2-sucess
  String poolName;

  Pool(this.user);

  Future<DocumentSnapshot> _getUserInfo(){
    return _firebase.document('users/${user.uid}').get();
  }

  //get List of possible Pools
  Future<Map<String, String>> fetchPoolSelection() async{
    DocumentSnapshot userDoc = await _getUserInfo();
    pools = {};
    if (!userDoc.exists){
      poolsRetrieved = 1;
      notifyListeners();
      return pools;
    } 
    if (userDoc['membership'] == null || userDoc['membership'].isEmpty){
      poolsRetrieved = 1;
      notifyListeners();
      return pools;
    }
    userDoc['membership'].forEach((key, value) => pools[key] = value);
    poolsRetrieved = pools.isEmpty ? 1 : 2;
    notifyListeners();
    return pools;
  }

  //choose Pool
  Future<void> setPool(String poolID) async{
    DocumentSnapshot poolSnap = await _firebase.document('pools/$poolID').get();
    if (!poolSnap.exists) throw "Chosen pool $poolID doesn't exist";
    if ((poolSnap['members'] == null) 
              || (poolSnap['founder'] == null)
              || (poolSnap['created'] == null)
              || (poolSnap['name'] == null)){
                throw "Pool $poolID.documentID is incomplete";
              }
    pool = poolID;
    poolName = poolSnap['name'];
    logList = LogList(_firebase.document('pools/$poolID'));
    await logList.fetchPoolMembers();
    user.role = logList.members[user.uid].role;     //Set Rule of the global UserModel depending on Pool
    notifyListeners();
    logList.refreshLogs();  //maybe switch aroung the last to? is there a difference?
  }
   

}