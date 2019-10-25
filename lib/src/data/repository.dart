import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_expenses/src/data/auth_provider.dart';
import 'package:shared_expenses/src/data/db_provider.dart';

import 'package:shared_expenses/src/res/models/event.dart';
import 'package:shared_expenses/src/res/models/user.dart';
import 'package:shared_expenses/src/res/db_strings.dart';

abstract class RepoInterface {
  Future<String> currentUserId();
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();

  Future<void> createGroup(String accountName, User user);
  Future<dynamic> getGroupByName(String name);
  Future<void> updateGroupName(String accountId, String name);
  Future<Map<String, String>> getGroupNames(List<String> accountIds);
  Future<List<String>> getGroupNamesList(List<String> accountIds);
  Future<bool> isGroupOwner(String userId, String groupId);
  Stream<Map<String, String>> userGroupsSubscription(String userId);

  Future<void> setTotals(String accountId, Map<String, double> totals);
  Stream<Map<String, num>> totalsStream(String accountId);

  Future<void> createUser(String userId, String email);
  Future<User> getUserFromDb(String userId);
  Stream<User> currentUserStream(String userId);
  Stream<List<User>> userStream(String accountId);
  Future<void> updateUserName(String userId, String name);
  Future<void> addUserToAccount(String userId, String accountId);
  Future<List<User>> usersWhere(String field, val);

  Future<void> createUserModifier(String accountId, UserModifier modifier);
  Future<void> updateUserModifier(String accountId, UserModifier modifier);
  Future<void> deleteUserModifier(String accountId, UserModifier modifier);
  Stream<List<UserModifier>> userModifierStream(String accountId);

  Stream<List<Payment>> paymentStream(String accountId);
  Future<void> createPayment(String accountId, Payment payment);
  Stream<List<Bill>> billStream(String accountId);
  Future<void> createBill(String accountId, Bill bill);
  Stream<List<AccountEvent>> accountEventStream(String accountId);
  Future<void> createAccountEvent(String accountId, AccountEvent event);
  Future<void> tabulateTotals(String accountId, List<User> users);

  Future<void> createAccountConnectionRequest(String accountId, String userId);
  Stream<List<Map<String, dynamic>>> connectionRequests(String accountId);
  Future<void> deleteConnectionRequest(String accountId, String request);

  Future<List<String>> getBillTypes(String accountId);
  Future<void> addBillType(String accountId, String billType);
  Future<void> deleteBillType(String accountId, String billType);
  Future<List<Bill>> billsWhere(String accountId, String field, val);

  Stream<List<String>> billTypeStream(String groupId);
}

class Repository implements RepoInterface {
  static Repository _theRepo = Repository();
  static Repository get getRepo => _theRepo;

  final DB _db = DatabaseManager();
  final Auth _auth = AuthProvider();

  //Authentication
  Future<String> currentUserId() {
    return _auth.getCurrentUser().then((user) {
      if (user == null) return null;
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

  Future<void> signOut() => _auth.signOut();

  Future<String> createGroup(String groupName, User user) async {
    // create group, make yourself admin

    return _db
        .createGroup(groupName, user.userId)
        .then((accountId) => accountId);
  }

  Future<dynamic> getGroupByName(String name) {
    return _db.getGroupsWhere(NAME, name).then((documents) {
      if (documents.length > 0)
        return documents[0].documentID;
      else
        return null;
    });
  }

  Future<Map<String, String>> getGroupNames(List<String> accountIds) {
    return _db.getGroupNames(accountIds).then((nameList) {
      Map<String, String> toReturn = {};
      for (int i = 0; i < accountIds.length; i++) {
        toReturn[accountIds[i]] = nameList[i];
      }
      return toReturn;
    });
  }

  Future<List<String>> getGroupNamesList(List<String> accountIds) {
    return _db.getGroupNames(accountIds);
  }

  Future<bool> isGroupOwner(String userId, String groupId) async {
    DocumentSnapshot groupSnap = await _db.getGroup(groupId);
    return groupSnap.data[OWNER] == userId;
  }

  Stream<Map<String, String>> userGroupsSubscription(String userId) {
    return _db.userGroupsStream(userId).map((query) {
      Map<String, String> groupIdToNameMap = Map<String, String>();
      query.documents.forEach((document) {
        groupIdToNameMap[document.documentID] = document.data[NAME];
      });
      return groupIdToNameMap;
    });
  }

  Future<void> updateGroupName(String accountId, String name) =>
      _db.updateGroup(accountId, NAME, name);
  Future<void> setTotals(String accountId, Map<String, double> totals) =>
      _db.updateTotals(accountId, totals);

  Stream<Map<String, num>> totalsStream(String accountId) {
    return _db
        .totalsStream(accountId)
        .map((DocumentSnapshot snapshot) => snapshot.data.cast<String, num>());
  }

  Future<void> createUser(String userId, String email) =>
      _db.createUser(userId, email);
  Future<User> getUserFromDb(String userId) =>
      _db.getUser(userId).then((user) => User.fromDocumentSnapshot(user));

  Stream<User> currentUserStream(String userId) {
    return _db.currentUserStream(userId).map((document) {
      document.data[ID] = document.documentID;
      return User.fromDocumentSnapshot(document);
    });
  }

  Stream<List<User>> userStream(String accountId) {
    return _db.usersStream(accountId).transform(
        StreamTransformer.fromHandlers(handleData: (ids, sink) async {
      List<User> users = await Future.wait(ids.map((id) => getUserFromDb(id)));
      sink.add(users);
    }));
  }

  Future<void> updateUserName(String userId, String name) =>
      _db.updateUser(userId, NAME, name);
  Future<void> addUserToAccount(String userId, String accountId) =>
      _db.addGroupToUser(userId, accountId);

  Future<List<User>> usersWhere(String field, val) {
    return _db.getUsersWhere(field, val).then((documents) => documents
        .map((document) => User.fromDocumentSnapshot(document))
        .toList());
  }

  Future<void> createUserModifier(
      String accountId, UserModifier modifier) async {
    await createAccountEvent(
        accountId,
        AccountEvent(
            userId: modifier.userId, actionTaken: ' modifier created'));
    return _db.createUserModifier(accountId, modifier.toJson());
  }

  Future<void> updateUserModifier(String accountId, UserModifier modifier) =>
      _db.updateUserModifier(accountId, modifier.modifierId, modifier.toJson());

  Future<void> deleteUserModifier(
      String accountId, UserModifier modifier) async {
    await createAccountEvent(
        accountId,
        AccountEvent(
            userId: modifier.userId, actionTaken: ' modifier removed'));
    return _db.deleteUserModifier(accountId, modifier.modifierId);
  }

  Stream<List<UserModifier>> userModifierStream(String accountId) {
    return _db.userModifierStream(accountId).map((snapshot) => snapshot
        .documents
        .map((document) => UserModifier.fromDocumentSnapshot(document))
        .toList());
  }

  Stream<List<Payment>> paymentStream(String accountId) {
    return _db.paymentStream(accountId, true).map((snapshot) => snapshot
        .documents
        .map((document) => Payment.fromJson(document.data))
        .toList());
  }

  Future<void> createPayment(String accountId, Payment payment) =>
      _db.createPayment(accountId, payment.toJson());

  Stream<List<Bill>> billStream(String accountId) {
    return _db.billStream(accountId, true).map((snapshot) => snapshot.documents
        .map((document) => Bill.fromJson(document.data))
        .toList());
  }

  Future<void> createBill(String accountId, Bill bill) =>
      _db.createBill(accountId, bill.toJson());

  Stream<List<AccountEvent>> accountEventStream(String accountId) {
    return _db.accountEventStream(accountId, true).map((snapshot) => snapshot
        .documents
        .map((document) => AccountEvent.fromJson(document.data))
        .toList());
  }

  Future<void> createAccountEvent(String accountId, AccountEvent event) =>
      _db.createAccountEvent(accountId, event.toJson());

  Future<void> tabulateTotals(String accountId, List<User> users) async {
    List<List<DocumentSnapshot>> futuresAwaited = await Future.wait([
      _db.allBills(accountId),
      _db.allPayments(accountId),
      _db.allUserModifiers(accountId)
    ]);

    List<DocumentSnapshot> bills = futuresAwaited[0];
    List<DocumentSnapshot> payments = futuresAwaited[1];
    List<DocumentSnapshot> userModifiers = futuresAwaited[2];

    //initiate totals arrays
    Map<String, num> totals = {};
    Map<String, num> paymentTotals = {};
    Map<String, num> billTotals = {};

    users.forEach((user) {
      totals[user.userId] = 0;
      paymentTotals[user.userId] = 0;
      billTotals[user.userId] = 0;
    });

    // instantiate bill, payment, and user modifier objects
    List<Bill> billObjs =
        bills.map((bill) => Bill.fromJson(bill.data)).toList();
    List<Payment> paymentObjs =
        payments.map((payment) => Payment.fromJson(payment.data)).toList();
    List<UserModifier> modifierObjs = userModifiers
        .map((modifier) => UserModifier.fromDocumentSnapshot(modifier))
        .toList();
    Map<String, List<UserModifier>> sortedModifiers = {};

    // sort user modifiers into map based on userId
    modifierObjs.forEach((modifier) {
      if (!sortedModifiers.containsKey(modifier.userId)) {
        sortedModifiers[modifier.userId] = [];
      }
      sortedModifiers[modifier.userId].add(modifier);
    });

    // tabulate payments
    paymentObjs.forEach((payment) {
      if (!paymentTotals.containsKey(payment.fromUserId))
        paymentTotals[payment.fromUserId] = 0;
      if (!paymentTotals.containsKey(payment.toUserId))
        paymentTotals[payment.toUserId] = 0;

      paymentTotals[payment.fromUserId] =
          paymentTotals[payment.fromUserId] - payment.amount;

      paymentTotals[payment.toUserId] =
          paymentTotals[payment.toUserId] + payment.amount;
    });

    //tabulate bills

    // for each bill, split into sub-bills for each overlapping user modifier date
    // dates and cateories must overlap for the modifier to apply, and a null value signifies applicability
    // applying a modifier means multiplying the user's share for that sub-bill by the the modified share
    // for each sub-bill, total user shares and divide the bill according to those shares. Apply each user's share x calculated share price to billTotals

    //identify the bills to remove and add for the successful split
    List<Bill> billsToRemove = [];
    List<Bill> billsToAdd = [];
    //for each bill, find split dates and split bill with splitBill method, then add bills to appropriate list above
    billObjs.forEach((bill) {
      List<DateTime> splitDates = [];
      modifierObjs.forEach((modifier) {
        if (modifier.categories == null ||
            modifier.categories.contains(bill.type)) {
          if (modifier.fromDate != null &&
              bill.fromDate.isBefore(modifier.fromDate) &&
              bill.toDate.isAfter(modifier.fromDate)) {
            splitDates.add(modifier.fromDate);
          }
          if (modifier.toDate != null &&
              bill.fromDate.isBefore(modifier.toDate) &&
              bill.toDate.isAfter(modifier.toDate)) {
            splitDates.add(modifier.toDate);
          }
        }
      });
      if (splitDates.isNotEmpty) {
        billsToRemove.add(bill);
        billsToAdd.addAll(Bill.splitBill(bill, splitDates));
      }
    });

    // now apply bills to add and bills to remove - bills are successfully split!
    billsToRemove.forEach(billObjs.remove);
    billsToAdd.forEach(billObjs.add);

    // for each bill, calculate total shares and apply each user's obligation and the user who paid the bill
    billObjs.forEach((bill) {
      Map<String, double> userShares = Map<String, double>.fromIterable(users,
          key: (user) => user.userId, value: (user) => 1);
      modifierObjs.forEach((modifier) {
        if (modifier.intersectsWithBill(bill)) {
          if (modifier.categories == null ||
              modifier.categories.contains(bill.type)) {
            userShares[modifier.userId] *= modifier.shares;
          }
        }
      });
      num totalShares = userShares.values.reduce((a, b) => a + b);
      if (totalShares == 0) return;
      num costPerShare = bill.amount / totalShares;
      totals[bill.paidByUserId] -= bill.amount;
      users.forEach((user) {
        totals[user.userId] += userShares[user.userId] * costPerShare;
      });
    });

    // round calculated totals to the penny
    totals.forEach((user, total) {
      totals[user] = (totals[user] * 100).round() / 100.0;
    });
    return _db.updateTotals(accountId, totals);
  }

  Future<void> createAccountConnectionRequest(
          String accountId, String userId) =>
      _db.createGroupConnectionRequest(accountId, userId);

  Stream<List<Map<String, dynamic>>> connectionRequests(String accountId) {
    return _db
        .groupConnectionRequests(accountId)
        .map((snapshot) => snapshot.documents.map((document) {
              document.data[ID] = document.documentID;
              return document.data;
            }).toList());
  }

  Future<void> deleteConnectionRequest(String accountId, String requestId) =>
      _db.deleteGroupConnectionRequest(accountId, requestId);

  Future<List<String>> getBillTypes(String accountId) {
    return _db.getBillTypes(accountId).then((snapshots) => List<String>.from(
        snapshots.map((snapshot) => snapshot.data[NAME]).toList()));
  }

  Future<List<Bill>> billsWhere(String accountId, String field, val) {
    return _db.billsWhere(accountId, field, val).then((snapshots) =>
        snapshots.map((snapshot) => Bill.fromJson(snapshot.data)).toList());
  }

  Stream<List<String>> billTypeStream(String groupId) {
    return _db.billCategories(groupId).map((snapshots) => List<String>.from(
        snapshots.map((snapshot) => snapshot.data[NAME]).toList()));
  }

  Future<void> addBillType(String accountId, String billType) =>
      _db.addBillType(accountId, billType);
  Future<void> deleteBillType(String accountId, String billType) =>
      _db.deleteBillType(accountId, billType);
}
