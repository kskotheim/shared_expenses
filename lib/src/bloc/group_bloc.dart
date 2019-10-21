import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
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
  List<User> _usersInAccount;
  List<User> get usersInAccount => _usersInAccount;
  List<String> _billTypes =  <String>[];
  List<String> get billTypes => _billTypes;

  List<DropdownMenuItem> get userMenuItems => _usersInAccount
      .map((user) => DropdownMenuItem(
            child: Text(user.userName),
            value: user.userId,
          ))
      .toList();

  List<DropdownMenuItem> get billTypeMenuItems => _billTypes
      .map((type) => DropdownMenuItem(
            child: Text(type),
            value: type,
          ))
      .toList();


  // this controlls whether to display the home or group management (or other?) page
  StreamController<GroupPageToShow> _groupPageToShowController = StreamController<GroupPageToShow>();
  Stream<GroupPageToShow> get groupPageToShowStream => _groupPageToShowController.stream;
  void showGroupHomePage() => _groupPageToShowController.sink.add(ShowGroupHomePage());
  void showGroupAdminPage() => _groupPageToShowController.sink.add(ShowGroupAdminPage());


  //group info
  Account currentAccount;

  //current user is group owner
  bool isGroupOwner;


  GroupBloc({this.accountId, this.userId, this.accountBloc}){
    _usersInAccountSubscription = repo.userStream(accountId).listen(_setAccountUsers);
    currentAccount = Account(accountId: accountId, accountName: accountBloc.accountNames[accountId]);
    setUpGroup();
  }


  void setUpGroup() async {
    await getPermissions();
    await getCategories();
    showGroupHomePage();
  }

  Future<void> getPermissions() async {
    isGroupOwner = await repo.isGroupOwner(userId, accountId);
    return;
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

  Future<void> deleteModifier(UserModifier modifier) async {
    return repo.deleteUserModifier(accountId, modifier);
  }

  String userName(String userId){
    if(usersInAccount != null){
      List<User> usersWithThatId;      
      usersWithThatId = usersInAccount.where((user) => user.userId == userId).toList();
      User user;
      if(usersWithThatId.isNotEmpty) user = usersWithThatId.removeLast();
      if(user != null) return user.userName;
      else return 'unknown user';
    } else return 'loading ...';
  }


  void _setAccountUsers(List<User> users){
    _usersInAccount = users;
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