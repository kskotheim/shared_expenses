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

  Future<void> createAccount(String accountName);
  Future<Account> getAccount(String accountId);
  Future<void> updateAccountName(String account, String name);
  Future<Map<String, String>> getAccountNames(List<String> accountIds);

  Future<void> createUser(String userId);
  Future<User> getUserFromDb(String userId);
  Future<List<AnyEvent>> getEvents();
  Future<void> createPayment(Map<String, dynamic> payment);
}

class Repository implements RepoInterface {
  String accountId = '-L_hpZnHAJAVkTGmdPZv';

  final DB db = DatabaseManager();
  final Auth auth = AuthProvider();

  //Authentication
  Future<String> currentUserId() {
    return auth.getCurrentUser().then((user) {
      if(user == null) return null;
      return user.uid;
    });
  }

  Future<String> signInWithEmailAndPassword(String email, String password) {
    return auth
        .signInWithEmailAndPassword(email, password)
        .then((user) => user.uid);
  }

  Future<String> createUserWithEmailAndPassword(String email, String password) {
    return auth
        .createUserWithEmailAndPassword(email, password)
        .then((user) => user.uid);
  }

  Future<void> signOut() {
    return auth.signOut();
  }

  Future<void> createAccount(String accountName) {
    return db.createAccount(accountName);
  }

  Future<Account> getAccount(String accountId) {
    return db
        .getAccount(accountId)
        .then((account) => Account.fromJson(account));
  }

  Future<Map<String, String>> getAccountNames(List<String> accountIds){
    return db.getAccountNames(accountIds).then((nameList){
      Map<String, String> toReturn = {};
      for(int i=0; i<accountIds.length; i++){
        toReturn[accountIds[i]] = nameList[i];
      }
      return toReturn;
    });
  }

  Future<void> updateAccountName(String account, String name) {
    return db.updateAccount(accountId, NAME, name);
  }

  Future<void> createUser(String userId) {
    return db.createUser(userId);
  }

  Future<User> getUserFromDb(String userId){
    return db.getUser(userId).then((user) => User(userId: userId, userName: user[NAME], accounts: List<String>.from(user[ACCOUNTS])));
  }

  Future<List<AnyEvent>> getEvents() {
    return db.getPayments(accountId).then(
        (events) => events.map((event) => Payment.fromJson(event)).toList());
  }

  Future<void> createPayment(Map<String, dynamic> payment) {
    return db.createPayment(accountId, payment);
  }
}
