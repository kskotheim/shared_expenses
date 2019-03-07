import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUser(String email, String password);
  Future<FirebaseUser> currentUser();
  Future<void> signOut();
  Future<void> resetPassword(String password);

}

class Auth implements BaseAuth{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signInWithEmailAndPassword(String email, String password) async {
    FirebaseUser user = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }

  Future<String> createUser(String email, String password) async {
    FirebaseUser user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }

  Future<FirebaseUser> currentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }
}