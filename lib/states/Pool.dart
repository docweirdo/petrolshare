import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:petrolshare/models/LogModel.dart';
import 'package:petrolshare/models/UserModel.dart';
import 'package:petrolshare/services/data.dart';
import 'package:petrolshare/states/LogList.dart';

enum LogState { notstarted, nologs, retrieved }

class Pool extends ChangeNotifier {
  String id;

  Map<String, String> members = {};

  LogState logState = LogState.notstarted;
  List<LogModel> logs = [];
}
