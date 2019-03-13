import 'package:cloud_firestore/cloud_firestore.dart';


abstract class DB {
  Future<void> createAccount(String accountName);
  Future<Map<String, dynamic>> getAccount(String accountId);
  Future<void> updateAccount(String accountId, String field, data);

  Future<void> createUser(String userId);
  Future<Map<String, dynamic>> getUser(String userId);
  Future<void> updateUser(String userId, String field, data);

  Future<void> createPayment(String accountId, Map<String, dynamic> payment);
  Future<List<Map<String, dynamic>>> getPayments(String accountId);
  Future<void> deletePayment(String accountId, String paymentId);
}

class DatabaseManager implements DB {

  static const String _ACCOUNTS = 'Accounts';
  static const String _USERS = 'Users';
  static const String _PAYMENTS = 'Payments';
  static const String _NAME = 'Name';
  static const String _CREATED = 'Created';

  Firestore firestore =Firestore.instance;


  Future<void> createAccount(String actName) async {
    return firestore.collection(_ACCOUNTS).document().setData({_NAME:actName});
  }

  Future<Map<String, dynamic>> getAccount(String accountId) async {
    return firestore.collection(_ACCOUNTS).document(accountId).get().then((snapshot) => snapshot.data);
  }

  Future<void> updateAccount(String accountId, String field, data) async {
    return firestore.collection(_ACCOUNTS).document(accountId).setData({field:data});
  }



  Future<void> createUser(String userId) async {
    return firestore.collection(_USERS).document(userId).setData({_CREATED:DateTime.now(), _ACCOUNTS:[]});
  }

  Future<Map<String, dynamic>> getUser(String userId) async {
    return firestore.collection(_USERS).document(userId).get().then((snapshot) => snapshot.data);
  }

  Future<void> updateUser(String userId, String field, data) async {
    return firestore.collection(_USERS).document(userId).updateData({field:data});
  }




  Future<void> createPayment(String accountId, Map<String, dynamic> payment) async {
    return firestore.collection(_ACCOUNTS).document(accountId).collection(_PAYMENTS).document().setData(payment);
  }

  Future<List<Map<String, dynamic>>> getPayments(String accountId) async {
    return firestore.collection(_ACCOUNTS).document(accountId).collection(_PAYMENTS).getDocuments().then((data){
      return data.documents.map((DocumentSnapshot snap) => snap.data).toList();
    });
  }

  Future<void> deletePayment(String accountId, String paymentId) async {
    return firestore.collection(_ACCOUNTS).document(accountId).collection(_PAYMENTS).document(paymentId).delete();
  }



  
}