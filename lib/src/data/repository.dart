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
  Future<void> updateUserName(String userId, String name);
  Future<List<AnyEvent>> getEvents();
  Future<void> createPayment(Map<String, dynamic> payment);
}

class Repository implements RepoInterface {

  static Repository _theRepo = Repository();
  static Repository get getRepo => _theRepo;

  String _accountId;
  void setAccountId(String id) => _accountId = id;

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

  Future<void> createAccount(String accountName) {
    return _db.createAccount(accountName);
  }

  Future<Account> getAccount(String accountId) {
    return _db
        .getAccount(accountId)
        .then((account) => Account.fromJson(account));
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

  Future<void> updateAccountName(String account, String name) {
    return _db.updateAccount(_accountId, NAME, name);
  }

  Future<void> createUser(String userId) {
    return _db.createUser(userId);
  }

  Future<User> getUserFromDb(String userId){
    return _db.getUser(userId).then((user) => User(userId: userId, userName: user[NAME], accounts: List<String>.from(user[ACCOUNTS])));
  }

  Future<void> updateUserName(String userId, String name){
    return _db.updateUser(userId, NAME, name);
  }

  Future<List<AnyEvent>> getEvents() {
    return _db.getPayments(_accountId).then(
        (events) => events.map((event) => Payment.fromJson(event)).toList());
  }

  Future<void> createPayment(Map<String, dynamic> payment) {
    return _db.createPayment(_accountId, payment);
  }
}
