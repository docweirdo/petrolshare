

import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petrolshare/models/LogModel.dart';
import 'package:petrolshare/models/UserModel.dart';

class LogList extends ChangeNotifier{

  List<LogModel> _logs = [];
  Map<String, UserModel> _members = {};
  DocumentReference _pool;
  bool hasBeenCalled = false; //has the refresh function been called at least once?

  UnmodifiableListView<LogModel> get logs => UnmodifiableListView(_logs);
  UnmodifiableMapView<String, UserModel> get members => UnmodifiableMapView(_members);


  LogList(this._pool);

  // get Entry count
  int get length => _logs.length;


  // add a new Entry, Log
  Future<void> add(LogModel log) async {
    await _pool.collection('logs').add(log.toMap())
    .then((value) {
      _logs.add(log);
      _logs.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    })
    .catchError((e) => e);
  }


  // get Logs from Firestore
  Future<UnmodifiableListView<LogModel>> refreshLogs() async {
    await fetchPoolMembers();
    Query query = _pool.collection('logs').orderBy('date', descending: true);
    return query.getDocuments()
      .then((value) {
        _logs = value.documents.map((DocumentSnapshot doc) {
            _members[doc['uid']] ??= UserModel(doc['uid'], "Monsieur Impossible", null, false, 'ghost'); 
            return LogModel.firebase(
              doc.documentID, 
              doc['uid'], 
              doc['roadmeter'], 
              doc['price'], 
              doc['amount'], 
              doc['date'], 
              _members[doc['uid']].name,
              doc['notes']);
            }
          ).toList();

        hasBeenCalled = true;
        notifyListeners();
        return this.logs;
      })
      .catchError((e){
        print(e.toString());
        return null;
      });
    
  }

  // fetch member info of current pool
  Future<void> fetchPoolMembers() async{
    DocumentSnapshot doc = await _pool.get();
    if (doc['members'] != null){
      _members = {};
      doc['members'].forEach((uid, properties) {
        _members[uid] = UserModel(uid, properties['name'], properties['photoURL'], true, properties['role']);
        });
      return;
    }
    else throw "Pool $_pool.documentID members field doesn't exist";
  }

}