import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:petrolshare/models/LogModel.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/services/data.dart';
import 'package:petrolshare/states/LogList.dart';
import 'dart:collection';

enum LogState { notstarted, nologs, retrieved }

class PoolState extends ChangeNotifier {
  String id;

  Map<String, UserModel> _members = {};

  LogState logState = LogState.notstarted;
  Map<String, LogModel> _logs = {};

  UnmodifiableListView<LogModel> get logs =>
      UnmodifiableListView(_logs.entries.map((entry) => entry.value)).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
  UnmodifiableMapView<String, UserModel> get members =>
      UnmodifiableMapView(_members);

  /// Number of Log Entries in Pool
  int get logCount => _logs.length;

  /// Updates the ID of the current Pool and listens to changed members
  void update(id) async {
    this.id = id;
    DataService.streamPoolMembers(id).listen(onUpdatedMembers);
    DataService.streamLogEntries(id).listen(onUpdatedLogs);
  }

  /// Gets called with new Membersmap.
  void onUpdatedMembers(Map<String, UserModel> newMembersMap) {
    _members = newMembersMap;
    // Do something else here, idk?
    notifyListeners();
  }

  void onUpdatedLogs(List<dynamic> updates) {
    List<LogModel> addedOrModified = updates[1];
    List<String> deleted = updates[2];

    addedOrModified.forEach((log) {
      _members[log.uid] ??= UserModel(log.uid, "Monsieur Impossible", null,
          role: UserRole.Member,
          isAnonymous: true); // Catch uids not present in members
      log.name = _members[log.uid].name;
      _logs[log.id] = log;
    });
    _logs.removeWhere((key, value) => deleted.contains(key));
    notifyListeners();
  }
}
