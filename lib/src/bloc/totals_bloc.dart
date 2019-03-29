import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/user.dart';

class TotalsBloc implements BlocBase {

  final AccountBloc accountBloc;
  final Repository repo =Repository();
  StreamSubscription _subscription;

  StreamController<List<ListTile>> _totalsListController = StreamController<List<ListTile>>();
  Stream<List<ListTile>> get totalsList => _totalsListController.stream;

  TotalsBloc({this.accountBloc}){

    _subscription = repo.userStream(accountBloc.currentAccount.accountId).listen(_addUsersToTotalsList);


  }

  void _addUsersToTotalsList(List<User> users){
    List<ListTile> totalsToShow = [];
    accountBloc.usersInAccount = users;
    users.forEach((user) => totalsToShow.add(ListTile(title: Text(user.userName), subtitle: Text(user.email))));
    _totalsListController.sink.add(totalsToShow);
  }

  @override
  void dispose() {
    _totalsListController.close();
    _subscription.cancel();
  }
}
