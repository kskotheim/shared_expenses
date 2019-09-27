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

  // this broadcasts updates to the list of users in the account
  BehaviorSubject<List<User>> _usersInAccountController = BehaviorSubject<List<User>>();
  Stream<List<User>> get usersInAccountStream => _usersInAccountController.stream;
  StreamSink get _usersInAccountSink => _usersInAccountController.sink;
  
  // this listens for updates to the list of users in the account
  StreamSubscription _usersInAccountSubscription;
  List<User> usersInAccount;
  List<String> _billTypes =  <String>[];
  List<String> get billTypes => _billTypes;

  // this controlls whether to display the home or group management (or other?) page
  StreamController<GroupPageToShow> _groupPageToShowController = StreamController<GroupPageToShow>();
  Stream<GroupPageToShow> get groupPageToShowStream => _groupPageToShowController.stream;
  void showGroupHomePage() => _groupPageToShowController.sink.add(ShowGroupHomePage());
  void showGroupAdminPage() => _groupPageToShowController.sink.add(ShowGroupAdminPage());


  //group info
  Account currentAccount;
  List<String> permissions;



  GroupBloc({this.accountId, this.userId, this.accountBloc}){
    usersInAccountStream.listen((List<User> users) => usersInAccount = users);
    _usersInAccountSubscription = repo.userStream(accountId).listen(_setAccountUsers);
    currentAccount = Account(accountId: accountId, accountName: accountBloc.accountNames[accountId]);
    permissions =  List<String>.from(accountBloc.currentUser.accountInfo[accountId][PERMISSIONS]);
    getCategories();
    showGroupHomePage();
  }

  Future<void> getCategories() async {
    return _billTypes = await repo.getBillTypes(accountId);
  }

  Future<void> deleteCategory(String category) async {
    if(_billTypes.contains(category)){
      // to do: check if there are any bills of this category
      // and verify if you want to delete them 
      // if so, delete all the bills, and the category

      return repo.deleteBillType(accountId, category);
    } else return Future.delayed(Duration(seconds: 0));
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
    _groupPageToShowController.close();
  }
}


class GroupPageToShow {}
class ShowGroupHomePage extends GroupPageToShow {}
class ShowGroupAdminPage extends GroupPageToShow {}