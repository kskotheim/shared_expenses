import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_expenses/src/res/db_strings.dart';

abstract class DB {
  Future<String> createGroup(String accountName, String userId);
  Future<void> updateGroup(String accountId, String field, data);
  Future<DocumentSnapshot> getGroup(String groupId);
  Future<List<String>> getGroupNames(List<String> accountIds);
  Future<List<DocumentSnapshot>> getGroupsWhere(String field, val);
  Stream<QuerySnapshot> userGroupsStream(String userId);

  Stream<DocumentSnapshot> totalsStream(String accountId);
  Future<void> updateTotals(String accountId, Map<String, num> totals);

  Future<void> createUser(String userId, String email);
  Future<DocumentSnapshot> getUser(String userId);
  Future<List<DocumentSnapshot>> getUsersWhere(String field, val);
  Stream<DocumentSnapshot> currentUserStream(String userId);
  Stream<List<String>> usersStream(String accountId);
  Future<void> updateUser(String userId, String field, data);
  Future<void> addGroupToUser(String userId, String accountId);

  Future<void> createGroupConnectionRequest(String accountId, String userId);
  Stream<QuerySnapshot> groupConnectionRequests(String accountId);
  Future<void> deleteGroupConnectionRequest(String accountId, String requestId);

  Future<void> createPayment(String accountId, Map<String, dynamic> payment);
  Stream<QuerySnapshot> paymentStream(String accountId, bool limited);
  Future<List<DocumentSnapshot>> allPayments(String accountId);
  Future<void> deletePayment(String accountId, String paymentId);

  Future<void> createBill(String accountId, Map<String, dynamic> bill);
  Stream<QuerySnapshot> billStream(String accountId, bool limited);
  Future<List<DocumentSnapshot>> allBills(String accountId);
  Future<void> deleteBill(String accountId, String billId);

  Future<void> createAccountEvent(String accountId, Map<String, dynamic> event);
  Stream<QuerySnapshot> accountEventStream(String accountId, bool limited);

  Future<List<DocumentSnapshot>> getBillTypes(String accountId);
  Future<List<DocumentSnapshot>> billsWhere(String accountId, String field, val);
  Stream<List<DocumentSnapshot>> categoriesStream(String accountId);
  Future<void> addBillType(String accountId, String bilLType);
  Future<void> deleteBillType(String accountId, String billType);
}

class DatabaseManager implements DB {
  Firestore _firestore = Firestore.instance;
  CollectionReference get _accountCollection => _firestore.collection(GROUPS);
  CollectionReference get _usersCollection => _firestore.collection(USERS);
  DocumentReference _account(String id) => _accountCollection.document(id);
  DocumentReference _user(String id) => _usersCollection.document(id);



  Future<String> createGroup(String actName, String userId) async {
    //create the group and get a reference for the document Id
    DocumentSnapshot newAcctSnap = await _accountCollection.document().get();

    // set the default group info
    await _account(newAcctSnap.documentID).setData({NAME: actName, OWNER: userId, USERS:[userId]});

    // create the totals document and set the default data
    await _account(newAcctSnap.documentID).collection(TOTALS).document(TOTALS).setData({userId:0});

    // // create the users collection and add this user
    // await _account(newAcctSnap.documentID).collection(USERS).document(userId).setData({});

    return newAcctSnap.documentID;
  }



  Future<void> updateGroup(String accountId, String field, data) async {
    return _account(accountId)
        .updateData({field: data});
  }

  Future<DocumentSnapshot> getGroup(String groupId) async {
    return _account(groupId).get();
  }

  Future<List<String>> getGroupNames(List<String> accountIds) async {
    return Future.wait(accountIds.map((accountId) => _account(accountId)
        .get()
        .then((snapshot) => snapshot.data != null ? snapshot.data.containsKey(NAME) ? snapshot.data[NAME] : 'no name' : 'no data')));
  } 

  Future<List<DocumentSnapshot>> getGroupsWhere(String field, val){
    return _accountCollection.where(field, isEqualTo: val).getDocuments().then((query) => query.documents);
  }

  Stream<QuerySnapshot> userGroupsStream(String userId) {
    return _accountCollection.where(USERS, arrayContains: userId).snapshots();
  }




  Stream<DocumentSnapshot> totalsStream(String accountId) {
    return _account(accountId).collection(TOTALS).document(TOTALS).snapshots();
  }




  Future<void> updateTotals(String accountId, Map<String, num> totals) async {
    return _account(accountId).collection(TOTALS).document(TOTALS).updateData(totals);
  }





  Future<void> createUser(String userId, String email) async {
    assert(userId != null, email != null);
    return _user(userId)
        .setData({CREATED: DateTime.now(), EMAIL: email});
  }

  Future<DocumentSnapshot> getUser(String userId) async {
    assert(userId != null);
    return _user(userId)
        .get();
  }

  Future<List<DocumentSnapshot>> getUsersWhere(String field, val) async {
    return _usersCollection.where(field, isEqualTo: val).getDocuments().then((snapshot) => snapshot.documents);
  }

  Stream<DocumentSnapshot> currentUserStream(String userId){
    return _user(userId).snapshots();
  }

  Stream<List<String>> usersStream(String accountId) {
    return _account(accountId).snapshots().map((groupSnap) => List<String>.from(groupSnap.data[USERS]));
  }

  Future<void> updateUser(String userId, String field, data) async {
    return _user(userId)
        .updateData({field: data});
  }



  Future<void> addGroupToUser(String userId, String accountId) async {
    WriteBatch batch =_firestore.batch();

    DocumentReference groupDocument = _account(accountId);
    DocumentSnapshot groupSnapshot = await groupDocument.get();
    List<String> users = List<String>.from(groupSnapshot.data[USERS]);
    users.add(userId);

    batch.updateData(groupDocument, {USERS:users});

    DocumentReference totalsDocument = _account(accountId).collection(TOTALS).document(TOTALS);
    DocumentSnapshot totalsSnapshot = await totalsDocument.get();
    Map<String, num> totals = Map<String, num>.from(totalsSnapshot.data);
    totals[userId] = 0;
    batch.updateData(totalsDocument, totals);

    // do something about dates 
    // Map<String, List<>> ;


    return batch.commit();
  }


  Future<void> createGroupConnectionRequest(String accountId, String userId) async {
    return _user(userId).get().then((user){
      return _user(userId).updateData({CONNECTION_REQUESTS: (user.data[CONNECTION_REQUESTS] ?? []) + [accountId]});

    });
  }

  Stream<QuerySnapshot> groupConnectionRequests(String accountId){
    return _usersCollection.where(CONNECTION_REQUESTS, arrayContains: accountId).snapshots();
  }

  Future<void> deleteGroupConnectionRequest(String accountId, String userId) async {
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

  Stream<QuerySnapshot> paymentStream(String accountId, bool limited) {
    if(limited)
      return _account(accountId).collection(PAYMENTS).orderBy('createdAt', descending: true).limit(10).snapshots();
    else
      return _account(accountId).collection(PAYMENTS).orderBy('createdAt', descending: true).snapshots();

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

  Stream<QuerySnapshot> billStream(String accountId, bool limited) {
    if(limited)
      return _account(accountId).collection(BILLS).orderBy('createdAt', descending: true).limit(10).snapshots();
    else 
      return _account(accountId).collection(BILLS).orderBy('createdAt', descending: true).snapshots();
  }

  Future<List<DocumentSnapshot>> allBills(String accountId) async{
    return _account(accountId).collection(BILLS).getDocuments().then((snapshot) => snapshot.documents);
  }

  Future<void> deleteBill(String accountId, String billId) async {
    return _account(accountId).collection(BILLS).document(billId).delete();
  }

  Future<List<DocumentSnapshot>> getBillTypes(String accountId) async {
    return _account(accountId).collection(BILL_TYPES).getDocuments().then((snapshot) => snapshot.documents);
  }

  Future<List<DocumentSnapshot>> billsWhere(String accountId, String field, val) async {
    return _account(accountId).collection(BILLS).where(field, isEqualTo: val).getDocuments().then((snapshot) => snapshot.documents);
  }


  Stream<QuerySnapshot> accountEventStream(String accountId, bool limited) {
    if(limited)
      return _account(accountId).collection(ACCOUNT_EVENTS).orderBy('createdAt', descending:true).limit(10).snapshots();
    else
      return _account(accountId).collection(ACCOUNT_EVENTS).orderBy('createdAt', descending:true).snapshots();
  }

  Future<void> createAccountEvent(String accountId, Map<String, dynamic> event) {
    return _account(accountId).collection(ACCOUNT_EVENTS).document().setData(event);
  }


  Stream<List<DocumentSnapshot>> categoriesStream(String groupId) {
    return _account(groupId).collection(BILL_TYPES).snapshots().map((snapshot) => snapshot.documents);
  }

  Future<void> addBillType(String accountId, String billType) async {
    return _account(accountId).collection(BILL_TYPES).document().setData({NAME:billType});
  }

  Future<void> deleteBillType(String accountId, String billType) async {
    List<String> id = await _account(accountId).collection(BILL_TYPES).where(NAME, isEqualTo: billType).getDocuments().then((snapshots) => snapshots.documents.map((document) => document.documentID).toList());
    if(id.isNotEmpty){
      return _account(accountId).collection(BILL_TYPES).document(id[0]).delete(); 
    }
    else return Future.delayed(Duration(seconds: 0));
  }


}