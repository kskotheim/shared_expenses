import 'package:shared_expenses/src/data/auth_provider.dart';
import 'package:shared_expenses/src/data/db_provider.dart';
import 'package:shared_expenses/src/models/account.dart';
import 'package:shared_expenses/src/models/payment.dart';
import 'package:shared_expenses/src/models/user.dart';
import 'package:shared_expenses/src/res/db_strings.dart';

abstract class RepoInterface {
  Future<User> currentUser();
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();

  Future<void> createAccount(String accountName);
  Future<Account> getAccount(String accountId);
  Future<void> updateAccountName(String account, String name);

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
  Future<User> currentUser() {
    return auth.getCurrentUser().then((user) {
      if(user == null) return null;
      return User.fromFirebaseUser(user);
    });
  }

  Future<User> signInWithEmailAndPassword(String email, String password) {
    return auth
        .signInWithEmailAndPassword(email, password)
        .then((user) => User.fromFirebaseUser(user));
  }

  Future<User> createUserWithEmailAndPassword(String email, String password) {
    return auth
        .createUserWithEmailAndPassword(email, password)
        .then((user) => User.fromFirebaseUser(user));
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

  Future<void> updateAccountName(String account, String name) {
    return db.updateAccount(accountId, NAME, name);
  }

  Future<void> createUser(String userId) {
    return db.createUser(userId);
  }

  Future<User> getUserFromDb(String userId){
    return db.getUser(userId).then((user) => User(userId: userId, userName: user[NAME], accounts: user[ACCOUNTS]));
  }

  Future<List<AnyEvent>> getEvents() {
    return db.getPayments(accountId).then(
        (events) => events.map((event) => Payment.fromJson(event)).toList());
  }

  Future<void> createPayment(Map<String, dynamic> payment) {
    return db.createPayment(accountId, payment);
  }
}
