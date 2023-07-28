import 'package:cloud_firestore/cloud_firestore.dart';

class LogModel {
  String id;
  String uid;
  var roadmeter;
  DateTime date;
  var price;
  var amount;
  String? name;
  String notes;

  LogModel(this.id, this.uid, this.roadmeter, this.price, this.amount,
      this.date, this.name, this.notes);

  LogModel.firebase(this.id, this.uid, this.roadmeter, this.price, this.amount,
      Timestamp date, this.notes)
      : this.date = date.toDate();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'roadmeter': roadmeter,
      'date': date,
      'price': price,
      'amount': amount,
      'notes': notes,
    };
  }
}
