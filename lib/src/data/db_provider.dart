import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_expenses/src/res/db_strings.dart';

abstract class DB {
  Future<String> createAccount(String accountName, String userId);
  Future<void> updateAccount(String accountId, String field, data);
  Future<List<String>> getAccountNames(List<String> accountIds);
  Future<List<DocumentSnapshot>> getAccountsWhere(String field, val);

  Stream<Map<String, num>> totalsStream(String accountId);
  Future<void> updateTotals(String accountId, Map<String, num> totals);

  Future<void> createUser(String userId, String email);
  Future<DocumentSnapshot> getUser(String userId);
  Stream<DocumentSnapshot> currentUserStream(String userId);
  Stream<QuerySnapshot> usersStream(String accountId);
  Future<void> updateUser(String userId, String field, data);
  Future<void> addAccountToUser(String userId, String accountId, String permission);

  Future<void> createAccountConnectionRequest(String accountId, String userId);
  Stream<QuerySnapshot> accountConnectionRequests(String accountId);
  Future<void> deleteAccountConnectionRequest(String accountId, String requestId);

  Future<void> createPayment(String accountId, Map<String, dynamic> payment);
  Stream<QuerySnapshot> paymentStream(String accountId);
  Future<List<DocumentSnapshot>> allPayments(String accountId);
  Future<void> deletePayment(String accountId, String paymentId);

  Future<void> createBill(String accountId, Map<String, dynamic> bill);
  Stream<QuerySnapshot> billStream(String accountId);
  Future<List<DocumentSnapshot>> allBills(String accountId);
  Future<void> deleteBill(String accountId, String billId);

  Future<void> setBillTypes(String accountId, List<String> billTypes);
  Future<List<String>> getBillTypes(String accountId);
  Future<List<DocumentSnapshot>> billsWhere(String accountId, String field, val);
}

class DatabaseManager implements DB {
  Firestore _firestore = Firestore.instance;
  CollectionReference get _accountCollection => _firestore.collection(GROUPS);
  CollectionReference get _usersCollection => _firestore.collection(USERS);
  DocumentReference _account(String id) => _accountCollection.document(id);
  DocumentReference _user(String id) => _usersCollection.document(id);

  Future<String> createAccount(String actName, String userId) async {
    return _accountCollection.document().get().then((document){
      return _account(document.documentID).setData({NAME: actName, TOTALS: {userId:0.0}}).then((_) => document.documentID);
    });
  }

  Future<void> updateAccount(String accountId, String field, data) async {
    return _account(accountId)
        .updateData({field: data});
  }

  Future<List<String>> getAccountNames(List<String> accountIds) async {
    return Future.wait(accountIds.map((accountId) => _account(accountId)
        .get()
        .then((snapshot) => snapshot.data != null ? snapshot.data.containsKey(NAME) ? snapshot.data[NAME] : 'no name' : 'no data')));
  } 

  Future<List<DocumentSnapshot>> getAccountsWhere(String field, val){
    return _accountCollection.where(field, isEqualTo: val).getDocuments().then((query) => query.documents);
  }


  Stream<Map<String, num>> totalsStream(String accountId) {
    return _account(accountId).snapshots().map((document) => Map<String, num>.from(document.data[TOTALS]) ?? <String, num>{});
  }

  Future<void> updateTotals(String accountId, Map<String, num> totals) async {
    return _account(accountId).updateData({TOTALS:totals});
  }


  Future<void> createUser(String userId, String email) async {
    assert(userId != null, email != null);
    return _user(userId)
        .setData({CREATED: DateTime.now(), GROUPS: [], ACCOUNT_INFO: {}, EMAIL: email});
  }

  Future<DocumentSnapshot> getUser(String userId) async {
    assert(userId != null);
    return _user(userId)
        .get();
  }

  Stream<DocumentSnapshot> currentUserStream(String userId){
    return _user(userId).snapshots();
  }

  Stream<QuerySnapshot> usersStream(String accountId) {
    return _usersCollection.where(GROUPS, arrayContains:accountId).snapshots();
  }

  Future<void> updateUser(String userId, String field, data) async {
    return _user(userId)
        .updateData({field: data});
  }

  Future<void> addAccountToUser(String userId, String accountId, String permission) async {
    WriteBatch batch =_firestore.batch();
    DocumentReference user =_user(userId);
    DocumentSnapshot userSnapshot = await user.get();

    batch.updateData(user, {GROUPS: userSnapshot[GROUPS] + [accountId]});

    Map thisAccount = {PERMISSIONS:[permission]};
    Map userAccountsInfo = userSnapshot.data[ACCOUNT_INFO];
    userAccountsInfo[accountId] = thisAccount;

    DocumentReference account = _account(accountId);
    DocumentSnapshot accountSnapshot = await account.get();
    Map<String, num> totals = Map<String, num>.from(accountSnapshot.data[TOTALS]);
    totals[userId] = 0;
    batch.updateData(account, {TOTALS:totals});

    batch.updateData(user, {ACCOUNT_INFO:userAccountsInfo});

    return batch.commit();
  }


  Future<void> createAccountConnectionRequest(String accountId, String userId) async {
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

  Stream<QuerySnapshot> paymentStream(String accountId) {
    return _account(accountId).collection(PAYMENTS).orderBy('createdAt', descending: true).limit(10).snapshots();
  }


  Future<List<DocumentSnapshot>> allPayments(String accountId) async{
    return _account(accountId).collection(PAYMENTS).getDocuments().then((snapshot) => snapshot.documents);
  }


  Future<void> deletePayment(String accountId, String paymentId) async {
    return _account(accountId)
        .collection(PAYMENTS)
        .document(paymentId)
        .delete();
  }

  Future<void> createBill(String accountId, Map<String, dynamic> bill) async {
    return _account(accountId).collection(BILLS).document().setData(bill);
  }

  Stream<QuerySnapshot> billStream(String accountId) {
    return _account(accountId).collection(BILLS).orderBy('createdAt', descending: true).limit(10).snapshots();
  }

  Future<List<DocumentSnapshot>> allBills(String accountId) async{
    return _account(accountId).collection(BILLS).getDocuments().then((snapshot) => snapshot.documents);
  }

  Future<void> deleteBill(String accountId, String billId) async {
    return _account(accountId).collection(BILLS).document(billId).delete();
  }

  Future<void> setBillTypes(String accountId, List<String> billTypes){
    return _account(accountId).updateData({BILL_TYPES: billTypes});
  }

  Future<List<String>> getBillTypes(String accountId) async {
    return _account(accountId).get().then((DocumentSnapshot account) => List<String>.from(account.data[BILL_TYPES]) ?? <String>[]);
  }

  Future<List<DocumentSnapshot>> billsWhere(String accountId, String field, val) async {
    return _account(accountId).collection(BILLS).where(field, isEqualTo: val).getDocuments().then((snapshot) => snapshot.documents);
  }

}