import 'package:firebase_auth/firebase_auth.dart';

class User{
  final String userId;
  String userName;
  List<String> accounts;

  User({this.userId, this.userName, this.accounts}): assert(userId != null);

  User.fromFirebaseUser(FirebaseUser user) :
    userId = user.uid;

}
