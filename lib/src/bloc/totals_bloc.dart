import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/user.dart';

class TotalsBloc implements BlocBase {

  final AccountBloc accountBloc;
  final Repository repo =Repository();
  StreamSubscription _usersSubscription;
  StreamSubscription _totalsSubscription;

  StreamController<List<ListTile>> _totalsListController = StreamController<List<ListTile>>();
  Stream<List<ListTile>> get totalsList => _totalsListController.stream;

  TotalsBloc({this.accountBloc}){

    _usersSubscription = 
    accountBloc.usersInAccountStream
    .listen(_addUsers);

    _totalsSubscription = 
    repo.totalsStream(accountBloc.currentAccount.accountId)
    .listen(_addTotals);


  }

  void _addUsers(List<User> users){
    List<ListTile> totalsToShow = [];
    users.forEach((user) => totalsToShow.add(ListTile(title: Text(user.userName), subtitle: Text(user.email))));
    _totalsListController.sink.add(totalsToShow);
  }

  void _addTotals(Map<String, double> totals){
    print('totals: ' + totals.toString());
  }

  @override
  void dispose() {
    _totalsListController.close();
    _usersSubscription.cancel();
    _totalsSubscription.cancel();
  }
}
