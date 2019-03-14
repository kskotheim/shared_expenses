import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_expenses/src/res/db_strings.dart';

abstract class DB {
  Future<void> createAccount(String accountName);
  Future<Map<String, dynamic>> getAccount(String accountId);
  Future<void> updateAccount(String accountId, String field, data);
  Future<List<String>> getAccountNames(List<String> accountIds);

  Future<void> createUser(String userId);
  Future<Map<String, dynamic>> getUser(String userId);
  Future<void> updateUser(String userId, String field, data);

  Future<void> createPayment(String accountId, Map<String, dynamic> payment);
  Future<List<Map<String, dynamic>>> getPayments(String accountId);
  Future<void> deletePayment(String accountId, String paymentId);
}

class DatabaseManager implements DB {
  Firestore firestore = Firestore.instance;

  Future<void> createAccount(String actName) async {
    return firestore.collection(ACCOUNTS).document().setData({NAME: actName});
  }

  Future<Map<String, dynamic>> getAccount(String accountId) async {
    return firestore
        .collection(ACCOUNTS)
        .document(accountId)
        .get()
        .then((snapshot) => snapshot.data);
  }

  Future<void> updateAccount(String accountId, String field, data) async {
    return firestore
        .collection(ACCOUNTS)
        .document(accountId)
        .setData({field: data});
  }

  Future<List<String>> getAccountNames(List<String> accountIds) async {
    return Future.wait(accountIds.map((accountId) => firestore
        .collection(ACCOUNTS)
        .document(accountId)
        .get()
        .then((snapshot) => snapshot.data[NAME])));
  }

  Future<void> createUser(String userId) async {
    return firestore
        .collection(USERS)
        .document(userId)
        .setData({CREATED: DateTime.now(), ACCOUNTS: []});
  }

  Future<Map<String, dynamic>> getUser(String userId) async {
    return firestore
        .collection(USERS)
        .document(userId)
        .get()
        .then((snapshot) => snapshot.data);
  }

  Future<void> updateUser(String userId, String field, data) async {
    return firestore
        .collection(USERS)
        .document(userId)
        .updateData({field: data});
  }

  Future<void> createPayment(
      String accountId, Map<String, dynamic> payment) async {
    return firestore
        .collection(ACCOUNTS)
        .document(accountId)
        .collection(PAYMENTS)
        .document()
        .setData(payment);
  }

  Future<List<Map<String, dynamic>>> getPayments(String accountId) async {
    return firestore
        .collection(ACCOUNTS)
        .document(accountId)
        .collection(PAYMENTS)
        .getDocuments()
        .then((data) {
      return data.documents.map((DocumentSnapshot snap) => snap.data).toList();
    });
  }

  Future<void> deletePayment(String accountId, String paymentId) async {
    return firestore
        .collection(ACCOUNTS)
        .document(accountId)
        .collection(PAYMENTS)
        .document(paymentId)
        .delete();
  }
}
