import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:petrolshare/models/LogModel.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/services/data.dart';
import 'dart:collection';

enum LogState { notstarted, nologs, retrieved }

class PoolState extends ChangeNotifier {
  String id;
  String name;

  Map<String, UserModel> _members = {};

  // Contains Fake UserModels of users mentioned in logs but not in Members
  List<UserModel> _fakeMembers = [];

  LogState logState = LogState.notstarted;
  Map<String, LogModel> _logs = {};

  StreamSubscription<Map<String, UserModel>> poolStream;
  StreamSubscription<List<dynamic>> logStream;

  UnmodifiableListView<LogModel> get logs =>
      UnmodifiableListView(_logs.entries.map((entry) => entry.value)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  UnmodifiableMapView<String, UserModel> get members =>
      UnmodifiableMapView(_members);

  /// Number of Log Entries in Pool
  int get logCount => _logs.length;

  /// Updates the ID of the current Pool and listens to changed members
  void update(String id, name) async {
    if (this.id == id || this.id == null) return;

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

    _fakeMembers.forEach((user) => _members[user.uid] = user);
    // Do something else here, idk?
    notifyListeners();
  }

  void onUpdatedLogs(List<dynamic> updates) {
    List<LogModel> addedOrModified = updates[1];
    List<String> deleted = updates[2];

    addedOrModified.forEach((log) {
      if (_members[log.uid] == null) {
        // Catch uids not present in members)
        _fakeMembers.add(UserModel(log.uid, "Monsieur Impossible", null,
            role: UserRole.Member, isAnonymous: true));
        _members[log.uid] = _fakeMembers.last;
      }

      log.name = _members[log.uid].name;
      _logs[log.id] = log;
    });
    _logs.removeWhere((key, value) => deleted.contains(key));

    logState = _logs.isEmpty ? LogState.nologs : LogState.retrieved;

    notifyListeners();
  }

  /// Adds a new Log Entry to the Pool
  Future<void> addLog(LogModel log) async {
    await DataService.addLog(log, id);
    _logs[log.id] = log;
  }

  Future<void> renamePool(String newPoolname) async {
    if (newPoolname.length > 15)
      throw "Poolname \"$newPoolname\" longer than 15 chars.";

    // Presumably triggers UserDoc Stream in AppState, so no further
    // action like updating Membership list and available pools?
    name = newPoolname;
    await DataService.renamePool(id, newPoolname);
    notifyListeners();
  }

  Future<void> makeAdmin(UserModel user) async {
    // TODO: Check for anonymity, possibly add field to membership map in DB
    await DataService.makeAdmin(user.uid, id);
  }
}
