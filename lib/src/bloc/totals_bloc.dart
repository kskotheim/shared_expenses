import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/db_strings.dart';

class TotalsBloc implements BlocBase {

  final AccountBloc accountBloc;
  final Repository repo =Repository();
  StreamSubscription _subscription;

  StreamController<List<Total>> _totalsListController = StreamController<List<Total>>();
  Stream<List<Total>> get totalsList => _totalsListController.stream;

  TotalsBloc({this.accountBloc}){

    _subscription = repo.userStream(accountBloc.currentAccount.accountId).listen(_addUsersToTotalsList);


  }

  void _addUsersToTotalsList(QuerySnapshot snapshot){
    List<Total> totalsToShow = [];
    snapshot.documents.forEach((doc) => totalsToShow.add(Total(name: doc.data[NAME])));
    _totalsListController.sink.add(totalsToShow);
  }

  @override
  void dispose() {
    _totalsListController.close();
    _subscription.cancel();
  }
}

class Total {
  final String name;
  Total({this.name});
}