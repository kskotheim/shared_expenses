import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/db_strings.dart';
import 'package:shared_expenses/src/res/models/account.dart';
import 'package:shared_expenses/src/res/models/user.dart';

class GroupBloc implements BlocBase {

  final Repository repo = Repository.getRepo;
  final String accountId;
  final String userId;
  final AccountBloc accountBloc;

  BehaviorSubject<List<User>> _usersInAccountController = BehaviorSubject<List<User>>();
  Stream<List<User>> get usersInAccountStream => _usersInAccountController.stream;
  StreamSink get _usersInAccountSink => _usersInAccountController.sink;
  
  StreamSubscription _usersInAccountSubscription;
  List<User> usersInAccount;
  List<String> _billTypes =  <String>[];
  List<String> get billTypes => _billTypes;

  //group info
  Account currentAccount;
  List<String> permissions;



  GroupBloc({this.accountId, this.userId, this.accountBloc}){
    usersInAccountStream.listen((List<User> users) => usersInAccount = users);
    _usersInAccountSubscription = repo.userStream(accountId).listen(_setAccountUsers);
    currentAccount = Account(accountId: accountId, accountName: accountBloc.accountNames[accountId]);
    permissions =  List<String>.from(accountBloc.currentUser.accountInfo[accountId][PERMISSIONS]);
    getCategories();
  }

  Future<void> getCategories() async {
    return _billTypes = await repo.getBillTypes(accountId);
  }

  String userName(String userId){
    if(usersInAccount != null){
    User user = usersInAccount.where((user) => user.userId == userId).toList().removeLast();
    if(user != null) return user.userName;
    else return 'no user by that id';
    } else return 'loading ...';
  }


  void _setAccountUsers(List<User> users){
    _usersInAccountSink.add(users);
  }

  
  @override
  void dispose() {
    _usersInAccountSubscription.cancel();
    _usersInAccountController.close();
  }
}