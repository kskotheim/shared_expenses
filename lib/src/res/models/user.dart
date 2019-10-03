import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_expenses/src/res/db_strings.dart';

class User{
  final String userId;
  String userName;
  List<String> connectionRequests;
  String email;

  User({this.userId, this.userName, this.email}): assert(userId != null);

  User.fromFirebaseUser(FirebaseUser user) :
    userId = user.uid;

  User.fromDocumentSnapshot(DocumentSnapshot user) :
    userId = user.documentID,
    userName = user.data[NAME],
    email = user.data[EMAIL],
    connectionRequests = List<String>.from(user.data[CONNECTION_REQUESTS] ?? []);

}
