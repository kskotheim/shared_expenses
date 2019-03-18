import 'dart:async';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';

class TotalsBloc implements BlocBase {

  final AccountBloc accountBloc;

  StreamController<List<Total>> _totalsListController = StreamController<List<Total>>();
  Stream<List<Total>> get totalsList => _totalsListController.stream;

  TotalsBloc({this.accountBloc}){
    List<Total> list = [
      Total(name: 'This is the totals from the account ${accountBloc.currentAccount.accountName}'),
    ];
    _totalsListController.sink.add(list);
  }


  @override
  void dispose() {
    _totalsListController.close();
  }
}

class Total {
  final String name;
  Total({this.name});
}