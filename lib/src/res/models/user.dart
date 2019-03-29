import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_expenses/src/res/db_strings.dart';

class User{
  final String userId;
  String userName;
  List<dynamic> accounts;
  List<String> connectionRequests;
  String email;
  Map<String, dynamic> accountInfo;

  User({this.userId, this.userName, this.accounts, this.email, this.accountInfo}): assert(userId != null);

  User.fromFirebaseUser(FirebaseUser user) :
    userId = user.uid;

  User.fromDocumentSnapshot(DocumentSnapshot user) :
    userId = user.documentID,
    userName = user.data[NAME],
    accounts = List<String>.from(user.data[ACCOUNTS] ?? []),
    email = user.data[EMAIL],
    accountInfo = Map<String, dynamic>.from(user.data[ACCOUNT_INFO] ?? {}),
    connectionRequests = List<String>.from(user.data[CONNECTION_REQUESTS] ?? []);

}
