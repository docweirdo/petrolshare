import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:petrolshare/models/LogModel.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/services/data.dart';
import 'package:petrolshare/states/LogList.dart';

enum LogState { notstarted, nologs, retrieved }

class Pool extends ChangeNotifier {
  String id;

  Map<String, UserModel> members = {};

  LogState logState = LogState.notstarted;
  List<LogModel> logs = [];

  /// Updates the ID of the current Pool and listens to changed members
  void update(id) async {
    this.id = id;
    DataService.streamPoolMembers(id).listen(onUpdatedMembers);
  }

  void onUpdatedMembers(Map<String, UserModel> newMembersMap) {
    // TODO: check changes and decide for notifyListeners
  }
}
