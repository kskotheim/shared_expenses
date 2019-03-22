import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_expenses/src/res/db_strings.dart';

class User{
  final String userId;
  String userName;
  List<dynamic> accounts;

  User({this.userId, this.userName, this.accounts}): assert(userId != null);

  User.fromFirebaseUser(FirebaseUser user) :
    userId = user.uid;

  User.fromDocumentSnapshot(DocumentSnapshot user) :
    userId = user.documentID,
    userName = user[NAME],
    accounts = List<String>.from(user[ACCOUNTS] ?? []);


}
