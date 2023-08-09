import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:petrolshare/models/LogModel.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/services/data.dart';
import 'package:petrolshare/states/AppState.dart';

import 'dart:collection';

enum LogState { notstarted, nologs, retrieved }

class PoolState extends ChangeNotifier {
  String? id;
  String? name;

  Map<String, UserModel> _members = {};

  // Contains Fake UserModels of users mentioned in logs but not in Members
  List<UserModel> _fakeMembers = [];

  LogState logState = LogState.notstarted;
  Map<String, LogModel> _logs = {};

  StreamSubscription<Map<String, UserModel>>? poolStream;
  StreamSubscription<List<dynamic>>? logStream;

  PoolStatus poolStatus = PoolStatus.notstarted;

  UnmodifiableListView<LogModel> get logs =>
      UnmodifiableListView(_logs.entries.map((entry) => entry.value).toList()
        ..sort((a, b) => b.date.compareTo(a.date)));
  UnmodifiableMapView<String, UserModel> get members =>
      UnmodifiableMapView(_members);

  /// Number of Log Entries in Pool
  int get logCount => _logs.length;

  /// Updates the ID of the current Pool and listens to changed members
  void update(String? id, String? name) async {
    if (id == null) return;
    if (this.id == id) {
      this.name = name;
      notifyListeners();
      return;
    }

    poolStream?.cancel();
    logStream?.cancel();

    this.id = id;
    this.name = name;

    _members = {};
    _fakeMembers = [];

    _logs = {};

    logState = LogState.notstarted;

    poolStream = DataService.streamPoolMembers(id).listen(onUpdatedMembers);
    logStream = DataService.streamLogEntries(id).listen(onUpdatedLogs);
  }

  /// Gets called with new Membersmap.
  void onUpdatedMembers(Map<String, UserModel> newMembersMap) {
    _members = newMembersMap;

    _fakeMembers.forEach((user) {
      if (_members.containsKey(user.uid)) return;
      _members[user.uid] = user;
    });

    _logs.forEach((key, value) {
      value.name = _members[value.uid]?.name;
    });
    // Do something else here, idk?

    debugPrint("PoolState: onUpdatedMembers() calls notifyListeners()");
    notifyListeners();
  }

  void onUpdatedLogs(List<dynamic> updates) {
    debugPrint("PoolState: onUpdatedLogs() fired");

    Map<String, LogModel> addedOrModified = updates[0];
    List<String> deleted = updates[1];

    addedOrModified.forEach((_, log) {
      if (_members[log.uid] == null) {
        // Catch uids not present in members)
        _fakeMembers.add(UserModel(log.uid, "Monsieur Impossible", null,
            role: UserRole.Member, isAnonymous: true));
        _members[log.uid] = _fakeMembers.last;
      }

      log.name = _members[log.uid]?.name;
      _logs[log.id] = log;
    });
    _logs.removeWhere((key, value) => deleted.contains(key));

    logState = LogState.retrieved;

    notifyListeners();
  }

  /// Adds a new Log Entry to the Pool
  Future<void> addLog(LogModel log) {
    return DataService.addLog(log, id!);
  }

  Future<void> renamePool(String newPoolname) async {
    if (newPoolname.length > 15)
      throw "Poolname \"$newPoolname\" longer than 15 chars.";

    // Presumably triggers UserDoc Stream in AppState, so no further
    // action like updating Membership list and available pools?
    name = newPoolname;
    await DataService.renamePool(id!, newPoolname);
    notifyListeners();
  }

  Future<void> makeAdmin(UserModel user) async {
    // TODO: Check for anonymity, possibly add field to membership map in DB
    await DataService.makeAdmin(user.uid, id!);
  }

  Future<void> removeMember(String userID) async {
    // Should trigger Membership Stream, no further action
    await DataService.removeMemberFromPool(userID, id!);
  }
}
