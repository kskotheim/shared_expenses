import 'package:shared_expenses/src/data/auth_provider.dart';
import 'package:shared_expenses/src/data/db_provider.dart';

import 'package:shared_expenses/src/res/models/payment.dart';
import 'package:shared_expenses/src/res/models/user.dart';
import 'package:shared_expenses/src/res/db_strings.dart';

abstract class RepoInterface {
  Future<String> currentUserId();
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();

  Future<void> createAccount(String accountName, User user);
  Future<dynamic> getAccountByName(String name);
  Future<void> updateAccountName(String accountId, String name);
  Future<Map<String, String>> getAccountNames(List<String> accountIds);
  Future<List<String>> getAccountNamesList(List<String> accountIds);

  Future<void> setTotals(String accountId, Map<String, double> totals);
  Stream<Map<String, num>> totalsStream(String accountId);

  Future<void> createUser(String userId, String email);
  Future<User> getUserFromDb(String userId);
  Stream<User> currentUserStream(String userId);
  Stream<List<User>> userStream(String accountId);
  Future<void> updateUserName(String userId, String name);
  Future<void> addUserToAccount(String userId, String accountId);

  Stream<List<Payment>> paymentStream(String accountId);
  Future<void> createPayment(String accountId, Payment payment);
  Stream<List<Bill>> billStream(String accountId);
  Future<void> createBill(String accountId, Bill bill);
  Future<void> tabulateTotals(String accountId);

  Future<void> createAccountConnectionRequest(String accountId, String userId);
  Stream<List<Map<String, dynamic>>> connectionRequests(String accountId);
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
    return _db.createAccount(accountName, user.userId).then((accountId){
      return _db.addAccountToUser(user.userId, accountId, 'owner').then((_) => accountId);
    });
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

  Future<void> setTotals(String accountId, Map<String, double> totals){
    return _db.updateTotals(accountId, totals);
  }

  Stream<Map<String, num>> totalsStream(String accountId){
    return _db.totalsStream(accountId);
  }

  Future<void> createUser(String userId, String email) {
    return _db.createUser(userId, email);
  }

  Future<User> getUserFromDb(String userId){
    return _db.getUser(userId).then((user) => User.fromDocumentSnapshot(user));
  }

  Stream<User> currentUserStream(String userId){
    return _db.currentUserStream(userId).map((document) {
      document.data[ID] =document.documentID;
      return User.fromDocumentSnapshot(document);
    });
  }

  Stream<List<User>> userStream(String accountId){
    return _db.usersStream(accountId).map((snapshot) => snapshot.documents.map((document) => User.fromDocumentSnapshot(document)).toList());
  }

  Future<void> updateUserName(String userId, String name){
    return _db.updateUser(userId, NAME, name);
  }

  Future<void> addUserToAccount(String userId, String accountId){
    return _db.getUser(userId).then((user){
      return _db.addAccountToUser(userId, accountId, 'user');
    });
  }

  Stream<List<Payment>> paymentStream(String accountId){
    return _db.paymentStream(accountId).map((snapshot) => snapshot.documents.map((document) => Payment.fromJson(document.data)).toList());
  }

  Future<void> createPayment(String accountId, Payment payment) {
    return _db.createPayment(accountId, payment.toJson());
  }

  Stream<List<Bill>> billStream(String accountId){
    return _db.billStream(accountId).map((snapshot) => snapshot.documents.map((document) => Bill.fromJson(document.data)).toList());
  }

  Future<void> createBill(String accountId, Bill bill) {
    return _db.createBill(accountId, bill.toJson());
  }

  Future<void> tabulateTotals(String accountId){
    return _db.allBills(accountId).then((bills){
      return _db.allPayments(accountId).then((payments){
        Map<String, num> totals = {};
        
        List<Bill> billObjs = bills.map((bill) => Bill.fromJson(bill.data)).toList();
        List<Payment> paymentObjs = payments.map((payment) => Payment.fromJson(payment.data)).toList();

        //tabulate payments
        paymentObjs.forEach((payment){
          if(!totals.containsKey(payment.fromUserId)) totals[payment.fromUserId] = 0;
          if(!totals.containsKey(payment.toUserId)) totals[payment.toUserId] = 0;

          totals[payment.fromUserId] = totals[payment.fromUserId] - payment.amount;

          totals[payment.toUserId] = totals[payment.toUserId] + payment.amount;
        });

        //tabulate bills
        num totalBillAmount = 0;

        billObjs.forEach((bill){
          if(!totals.containsKey(bill.paidByUserId)) totals[bill.paidByUserId] = 0;

          totals[bill.paidByUserId] = totals[bill.paidByUserId] - bill.amount;
          totalBillAmount += bill.amount;
        });

        int numUsers = totals.keys.length;
        num userObligation = 0;

        if(numUsers != 0) userObligation = totalBillAmount / numUsers;

        totals.forEach((user, total) => totals[user] = total + userObligation);

        return _db.updateTotals(accountId, totals);

      });
    });
  }


  Future<void> createAccountConnectionRequest(String accountId, String userId) {
    return _db.createAccountConnectionRequest(accountId, userId);
  }

  Stream<List<Map<String, dynamic>>> connectionRequests(String accountId){
    return _db.accountConnectionRequests(accountId).map((snapshot) => snapshot.documents.map((document) {
      document.data[ID] =document.documentID;
      return document.data;
    }).toList());
  }

  Future<void> deleteConnectionRequest(String accountId, String requestId){
    return _db.deleteAccountConnectionRequest(accountId, requestId);
  }
}
