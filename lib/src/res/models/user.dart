import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_expenses/src/res/db_strings.dart';
import 'package:shared_expenses/src/res/models/event.dart';

class User {
  final String userId;
  String userName;
  List<String> connectionRequests;
  String email;

  User({this.userId, this.userName, this.email}) : assert(userId != null);

  User.fromFirebaseUser(FirebaseUser user) : userId = user.uid;

  User.fromDocumentSnapshot(DocumentSnapshot user)
      : userId = user.documentID,
        userName = user.data[NAME],
        email = user.data[EMAIL],
        connectionRequests =
            List<String>.from(user.data[CONNECTION_REQUESTS] ?? []);
}

class UserModifier {
  final String userId;
  final String modifierId;
  final num shares;
  DateTime fromDate;
  DateTime toDate;
  List<String> categories;

  UserModifier(
      {@required this.userId,
      @required this.shares,
      this.modifierId,
      this.fromDate,
      this.toDate,
      this.categories})
      : assert(userId != null),
        assert(shares != null);

  UserModifier.fromDocumentSnapshot(DocumentSnapshot userModifier)
      : userId = userModifier.data[USER],
        modifierId = userModifier.documentID,
        shares = userModifier.data[SHARES],
        fromDate = userModifier.data.containsKey(FROM)
            ? parseTime(userModifier.data[FROM])
            : null,
        toDate = userModifier.data.containsKey(TO)
            ? parseTime(userModifier.data[TO])
            : null,
        categories = userModifier.data.containsKey(CATEGORIES)
            ? List<String>.from(userModifier.data[CATEGORIES])
            : null;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> modifier = {USER: userId, SHARES: shares};
    if (fromDate != null) {
      modifier[FROM] = fromDate;
    }
    if (toDate != null) {
      modifier[TO] = toDate;
    }
    if (categories != null) {
      modifier[CATEGORIES] = categories;
    }
    return modifier;
  }

  bool intersectsWithBill(Bill bill) {
    return (fromDate == null && toDate == null) ||
        (fromDate == null && toDate.isAfter(bill.toDate)) ||
        (toDate == null && fromDate.isBefore(bill.fromDate)) ||
        ((fromDate != null && fromDate.isAtSameMomentAs(bill.fromDate)) ||
            (toDate != null && toDate.isAtSameMomentAs(bill.toDate)) ||
            (fromDate != null &&
                toDate != null &&
                fromDate.isBefore(bill.fromDate) &&
                toDate.isAfter(bill.toDate)));
  }
}

DateTime parseTime(dynamic date) {
  assert(date is Timestamp || date is DateTime);
  return (date is Timestamp) ? date.toDate() : (date as DateTime);
}
