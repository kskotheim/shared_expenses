import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_expenses/src/res/db_strings.dart';

abstract class DB {
  Future<String> createAccount(String accountName);
  Future<Map<String, dynamic>> getAccount(String accountId);
  Future<void> updateAccount(String accountId, String field, data);
  Future<List<String>> getAccountNames(List<String> accountIds);
  Future<List<DocumentSnapshot>> getAccountsWhere(String field, val);

  Future<void> createUser(String userId, String email);
  Future<DocumentSnapshot> getUser(String userId);
  Stream<DocumentSnapshot> currentUserStream(String userId);
  Stream<QuerySnapshot> userStream(String accountId);
  Future<void> updateUser(String userId, String field, data);

  Future<void> createAccountConnectionRequest(String accountId, String userId);
  Stream<QuerySnapshot> accountConnectionRequests(String accountId);
  Future<void> deleteAccountConnectionRequest(String accountId, String requestId);

  Future<void> createPayment(String accountId, Map<String, dynamic> payment);
  Future<List<Map<String, dynamic>>> getPayments(String accountId);
  Future<void> deletePayment(String accountId, String paymentId);
}

class DatabaseManager implements DB {
  Firestore _firestore = Firestore.instance;
  CollectionReference get _accountCollection => _firestore.collection(ACCOUNTS);
  CollectionReference get _usersCollection => _firestore.collection(USERS);
  DocumentReference _account(String id) => _accountCollection.document(id);
  DocumentReference _user(String id) => _usersCollection.document(id);

  Future<String> createAccount(String actName) async {
    return _accountCollection.document().get().then((document){
      return _account(document.documentID).setData({NAME: actName}).then((_){
        return document.documentID;
      });
    });
  }

  Future<Map<String, dynamic>> getAccount(String accountId) async {
    return _account(accountId).get().then((snapshot) => snapshot.data);
  }

  Future<void> updateAccount(String accountId, String field, data) async {
    return _account(accountId)
        .setData({field: data});
  }

  Future<List<String>> getAccountNames(List<String> accountIds) async {
    return Future.wait(accountIds.map((accountId) => _account(accountId)
        .get()
        .then((snapshot) => snapshot.data[NAME])));
  } 

  Future<List<DocumentSnapshot>> getAccountsWhere(String field, val){
    return _accountCollection.where(field, isEqualTo: val).getDocuments().then((query) => query.documents);
  }

  Future<void> createUser(String userId, String email) async {
    assert(userId != null, email != null);
    return _user(userId)
        .setData({CREATED: DateTime.now(), ACCOUNTS: [], ACCOUNT_INFO: {}, EMAIL: email});
  }

  Future<DocumentSnapshot> getUser(String userId) async {
    assert(userId != null);
    return _user(userId)
        .get();
  }

  Stream<DocumentSnapshot> currentUserStream(String userId){
    return _user(userId).snapshots();
  }

  Stream<QuerySnapshot> userStream(String accountId) {
    return _usersCollection.where(ACCOUNTS, arrayContains:accountId).snapshots();
  }

  Future<void> updateUser(String userId, String field, data) async {
    return _user(userId)
        .updateData({field: data});
  }

  Future<void> createAccountConnectionRequest(String accountId, String userId) async {
    print('creating account connection request');
    return _user(userId).get().then((user){
      return _user(userId).updateData({CONNECTION_REQUESTS: (user.data[CONNECTION_REQUESTS] ?? []) + [accountId]});

    });
  }

  Stream<QuerySnapshot> accountConnectionRequests(String accountId){
    return _usersCollection.where(CONNECTION_REQUESTS, arrayContains: accountId).snapshots();
  }

  Future<void> deleteAccountConnectionRequest(String accountId, String userId) async {
    return _user(userId).get().then((user){
      List<String> connectionRequests = List<String>.from(user.data[CONNECTION_REQUESTS] ?? []);
      while(connectionRequests.contains(accountId)) connectionRequests.remove(accountId);
      return _user(userId).updateData({CONNECTION_REQUESTS: connectionRequests});
    });
  }

  Future<void> createPayment(
      String accountId, Map<String, dynamic> payment) async {
    return _account(accountId)
        .collection(PAYMENTS)
        .document()
        .setData(payment);
  }

  Future<List<Map<String, dynamic>>> getPayments(String accountId) async {
    return _account(accountId)
        .collection(PAYMENTS)
        .getDocuments()
        .then((data) {
      return data.documents.map((DocumentSnapshot snap) => snap.data).toList();
    });
  }

  Future<void> deletePayment(String accountId, String paymentId) async {
    return _account(accountId)
        .collection(PAYMENTS)
        .document(paymentId)
        .delete();
  }
}