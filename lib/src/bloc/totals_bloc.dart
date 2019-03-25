import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/db_strings.dart';

class TotalsBloc implements BlocBase {

  final AccountBloc accountBloc;
  final Repository repo =Repository();
  StreamSubscription _subscription;

  StreamController<List<ListTile>> _totalsListController = StreamController<List<ListTile>>();
  Stream<List<ListTile>> get totalsList => _totalsListController.stream;

  TotalsBloc({this.accountBloc}){

    _subscription = repo.userStream(accountBloc.currentAccount.accountId).listen(_addUsersToTotalsList);


  }

  void _addUsersToTotalsList(QuerySnapshot snapshot){
    List<ListTile> totalsToShow = [];
    snapshot.documents.forEach((doc) => totalsToShow.add(ListTile(title: Text(doc.data[NAME]), subtitle: Text(doc.data[EMAIL]))));
    _totalsListController.sink.add(totalsToShow);
  }

  @override
  void dispose() {
    _totalsListController.close();
    _subscription.cancel();
  }
}
