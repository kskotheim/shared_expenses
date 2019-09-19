import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/user.dart';

class TotalsBloc implements BlocBase {
  final GroupBloc groupBloc;
  final Repository repo = Repository();
  StreamSubscription _usersSubscription;
  StreamSubscription _totalsSubscription;

  StreamController<List<ListTile>> _totalsListController = StreamController<List<ListTile>>();
  Stream<List<ListTile>> get totalsList => _totalsListController.stream;

  List<User> _users;
  Map<String, num> _idTotals;
  Totals _totals;

  TotalsBloc({this.groupBloc}) {
    _usersSubscription = groupBloc.usersInAccountStream.listen(_addUsers);

    _totalsSubscription = repo
        .totalsStream(groupBloc.accountId)
        .listen(_addTotals);
  }

  void _addUsers(List<User> users) {
    _users = users;

    _checkAndPropagateTotals();
  }

  void _addTotals(Map<String, num> totals) {
    _idTotals = totals;

    _checkAndPropagateTotals();
  }

  void _checkAndPropagateTotals() {
    //check if we have users and totals
    if (_users != null && _idTotals != null) {
      //make totals
      _totals = Totals();

      _idTotals.forEach((id, total) {
        List<User> theUser = _users.where((user) => user.userId == id).toList();
        if (theUser.length == 1) {
          String username = theUser[0].userName ?? 'unnamed user';
          _totals.addTotal(username, total);
        } else {
          print('couldnt find user $id in account ${groupBloc.accountId}');
        }
      });

      //add totals to sink
      _totalsListController.sink.add(_totals.getTotals);
    }
    //if not, wait ...
  }

  @override
  void dispose() {
    _totalsListController.close();
    _usersSubscription.cancel();
    _totalsSubscription.cancel();
  }
}

class Totals {
  Map<String, num> _totals = {};

  void addTotal(String name, num amount) {
    _totals[name] = amount;
  }

  List<ListTile> get getTotals => _totals.entries
      .map((entry) => ListTile(
              title: Text(
            '${entry.key}: \$${entry.value}',
            style: TextStyle(color: entry.value < -1 ? Colors.green : entry.value > 1 ? Colors.red : Colors.black),
          )))
      .toList();

  void resetTotal() => _totals = {};
}