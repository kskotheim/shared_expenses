import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/db_strings.dart';


class RequestsBloc implements BlocBase {
  
  final Repository _repo = Repository();
  final AccountBloc accountBloc;

  StreamController<List<String>> _requestsStream = StreamController<List<String>>();
  Stream<List<String>> get requests => _requestsStream.stream;

  RequestsBloc({this.accountBloc}){
    assert(accountBloc != null);
    _repo.connectionRequests(accountBloc.currentAccount.accountId).listen(_mapSnapshotToStream);
  }
  
  void _mapSnapshotToStream(QuerySnapshot snapshot) async {
    List<String> names = await Future.wait(snapshot.documents.map((document){
      return _repo.getUserFromDb(document.data[USER]).then((user){
        return user.userName;
      });
    }));
    _requestsStream.sink.add(names);
  }
  
  
  @override
  void dispose() {
    _requestsStream.close();
  }
}
