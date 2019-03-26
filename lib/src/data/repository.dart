import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_expenses/src/data/auth_provider.dart';
import 'package:shared_expenses/src/data/db_provider.dart';
import 'package:shared_expenses/src/res/models/account.dart';
import 'package:shared_expenses/src/res/models/payment.dart';
import 'package:shared_expenses/src/res/models/user.dart';
import 'package:shared_expenses/src/res/db_strings.dart';

abstract class RepoInterface {
  Future<String> currentUserId();
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();

  Future<void> createAccount(String accountName, User user);
  Future<Account> getAccount(String accountId);
  Future<dynamic> getAccountByName(String name);
  Future<void> updateAccountName(String accountId, String name);
  Future<Map<String, String>> getAccountNames(List<String> accountIds);
  Future<List<String>> getAccountNamesList(List<String> accountIds);

  Future<void> createUser(String userId, String email);
  Future<User> getUserFromDb(String userId);
  Stream<DocumentSnapshot> currentUserStream(String userId);
  Stream<QuerySnapshot> userStream(String accountId);
  Future<void> updateUserName(String userId, String name);
  Future<void> addUserToAccount(String userId, String accountId);
  Future<List<AnyEvent>> getEvents(String accountId);
  Stream<QuerySnapshot> paymentStream(String accountId);
  Future<void> createPayment(String accountId, Map<String, dynamic> payment);

  Future<void> createAccountConnectionRequest(String accountId, String userId);
  Stream<QuerySnapshot> connectionRequests(String accountId);
  Future<void> deleteConnectionRequest(String accountId, String request);

}

class Repository implements RepoInterface {

  static Repository _theRepo = Repository();
  static Repository get getRepo => _theRepo;

  final DB _db = DatabaseManager();
  final Auth _auth = AuthProvider();

  //Authentication
  Future<String> currentUserId() {
    return _auth.getCurrentUser().then((user) {
      if(user == null) return null;
      return user.uid;
    });
  }

  Future<String> signInWithEmailAndPassword(String email, String password) {
    return _auth
        .signInWithEmailAndPassword(email, password)
        .then((user) => user.uid);
  }

  Future<String> createUserWithEmailAndPassword(String email, String password) {
    return _auth
        .createUserWithEmailAndPassword(email, password)
        .then((user) => user.uid);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<String> createAccount(String accountName, User user) async {
    return _db.createAccount(accountName).then((accountId){
      return _db.addAccountToUser(user.userId, accountId, 'owner').then((_) => accountId);
    });
  }

  Future<Account> getAccount(String accountId) {
    return _db
        .getAccount(accountId)
        .then((account) => Account.fromJson(account));
  }

  Future<dynamic> getAccountByName(String name){
    return _db.getAccountsWhere(NAME, name).then((documents) {
      if(documents.length > 0) return documents[0].documentID;
      else return null;
    });
  }

  Future<Map<String, String>> getAccountNames(List<String> accountIds){
    return _db.getAccountNames(accountIds).then((nameList){
      Map<String, String> toReturn = {};
      for(int i=0; i<accountIds.length; i++){
        toReturn[accountIds[i]] = nameList[i];
      }
      return toReturn;
    });
  }

  Future<List<String>> getAccountNamesList(List<String> accountIds){
    return _db.getAccountNames(accountIds);
  }

  Future<void> updateAccountName(String accountId, String name) {
    return _db.updateAccount(accountId, NAME, name);
  }

  Future<void> createUser(String userId, String email) {
    return _db.createUser(userId, email);
  }

  Future<User> getUserFromDb(String userId){
    return _db.getUser(userId).then((user) => User.fromDocumentSnapshot(user));
  }

  Stream<DocumentSnapshot> currentUserStream(String userId){
    return _db.currentUserStream(userId);
  }

  Stream<QuerySnapshot> userStream(String accountId){
    return _db.userStream(accountId);
  }

  Future<void> updateUserName(String userId, String name){
    return _db.updateUser(userId, NAME, name);
  }

  Future<void> addUserToAccount(String userId, String accountId){
    return _db.getUser(userId).then((user){
      return _db.addAccountToUser(userId, accountId, 'user');
    });
  }

  Future<List<AnyEvent>> getEvents(String accountId) {
    return _db.getPayments(accountId).then(
        (events) => events.map((event) => Payment.fromJson(event)).toList());
  }

  Stream<QuerySnapshot> paymentStream(String accountId){
    return _db.paymentStream(accountId);
  }

  Future<void> createPayment(String accountId, Map<String, dynamic> payment) {
    return _db.createPayment(accountId, payment);
  }

  Future<void> createAccountConnectionRequest(String accountId, String userId) {
    return _db.createAccountConnectionRequest(accountId, userId);
  }

  Stream<QuerySnapshot> connectionRequests(String accountId){
    return _db.accountConnectionRequests(accountId);
  }

  Future<void> deleteConnectionRequest(String accountId, String requestId){
    return _db.deleteAccountConnectionRequest(accountId, requestId);
  }



}
