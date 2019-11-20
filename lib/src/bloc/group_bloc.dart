import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/account.dart';
import 'package:shared_expenses/src/res/models/user.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/res/util.dart';

class GroupBloc implements BlocBase {
  final Repository repo = Repository.getRepo;
  final String userId;
  final Account currentGroup;
  final AccountBloc accountBloc;
  final BuildContext context;

  String get groupId => currentGroup.accountId;

  // this broadcasts updates to the list of users in the account
  BehaviorSubject<List<User>> _usersInAccountController =
      BehaviorSubject<List<User>>();
  Stream<List<User>> get usersInAccountStream =>
      _usersInAccountController.stream;
  StreamSink get _usersInAccountSink => _usersInAccountController.sink;

  // this listens for updates to the list of users in the account
  StreamSubscription _usersInAccountSubscription;
  List<User> _usersInAccount;
  List<User> get usersInAccount => _usersInAccount;

  StreamSubscription _billTypesSubscription;
  List<String> _billTypes = <String>[];
  List<String> get billTypes => _billTypes;

  StreamSubscription _userModifierSubscription;
  List<UserModifier> _userModifiers;
  List<UserModifier> get userModifiers => _userModifiers;

  // this controlls whether to display the home or group management (or other?) page
  StreamController<GroupPageToShow> _groupPageToShowController =
      StreamController<GroupPageToShow>();
  Stream<GroupPageToShow> get groupPageToShowStream =>
      _groupPageToShowController.stream;
  void showGroupHomePage() =>
      _groupPageToShowController.sink.add(ShowGroupHomePage());
  void showGroupAdminPage() =>
      _groupPageToShowController.sink.add(ShowGroupAdminPage());


  //current user is group owner
  bool isGroupOwner;

  GroupBloc({this.currentGroup, this.userId, this.accountBloc, this.context}) {
    _usersInAccountSubscription =
        repo.userStream(currentGroup.accountId).listen(_setAccountUsers);
    _userModifierSubscription =
        repo.userModifierStream(currentGroup.accountId).listen(_setUserModifiers);
    _billTypesSubscription = repo.billTypeStream(currentGroup.accountId).listen(_setBillTypes);
    setUpGroup();
  }

  void setUpGroup() async {
    await getPermissions();
    await getCategories();
    showGroupHomePage();
  }

  Future<void> getPermissions() async {
    isGroupOwner = await repo.isGroupOwner(userId, groupId);
  }

  Future<void> getCategories() async {
    _billTypes = await repo.getBillTypes(groupId);
    if (_billTypes.isEmpty) {
      InitialCategoryDialogController(currentAccount: currentGroup).showNoCategoriesDialog(context);
    }
  }

  Future<void> deleteCategory(String category) async {
    if (_billTypes.contains(category)) {
      // to do: check if there are any bills of this category
      // and verify if you want to delete them
      // if so, delete all the bills, and the category

      return repo.deleteBillType(groupId, category);
    } else
      return Future.delayed(Duration(seconds: 0));
  }

  Future<void> deleteModifier(UserModifier modifier) async {
    return repo.deleteUserModifier(groupId, modifier);
  }

  String userName(String userId) {
    if (usersInAccount != null) {
      List<User> usersWithThatId;
      usersWithThatId =
          usersInAccount.where((user) => user.userId == userId).toList();
      User user;
      if (usersWithThatId.isNotEmpty) user = usersWithThatId.removeLast();
      if (user != null)
        return user.userName;
      else
        return 'unknown user';
    } else
      return 'loading ...';
  }

  void _setAccountUsers(List<User> users) {
    _usersInAccount = users;
    _usersInAccountSink.add(users);
  }

  void _setUserModifiers(List<UserModifier> modifiers) {
    _userModifiers = modifiers;
  }

  void _setBillTypes(List<String> billTypes) {
    _billTypes = billTypes;
  }

  @override
  void dispose() {
    _usersInAccountController.close();
    _groupPageToShowController.close();
    _usersInAccountSubscription.cancel();
    _userModifierSubscription.cancel();
    _billTypesSubscription.cancel();
  }

  //for debugging
  void tabulateTotals() {
    repo.tabulateTotals(groupId).then((_) => print('tabulated'));
  }
}

class GroupPageToShow {}

class ShowGroupHomePage extends GroupPageToShow {}

class ShowGroupAdminPage extends GroupPageToShow {}

class InitialCategoryDialogController {
  // this is for asking the group owner for initial categories when they first open the group
  final Account currentAccount;

  InitialCategoryDialogController({this.currentAccount});

  static Repository repo = Repository.getRepo;
  static List<bool> _initialCategories = [
    true,
    false,
    false,
    false,
    false,
    false
  ];
  BehaviorSubject<List<bool>> _initialCategoriesSelected =
      BehaviorSubject<List<bool>>.seeded(_initialCategories);
  BehaviorSubject<bool> _initialCategoriesSelectedValid =
      BehaviorSubject<bool>.seeded(_initialCategories.reduce((a, b) => a || b));

  void _toggleNewCategorySelected(int i) {
    _initialCategories[i] = !_initialCategories[i];
    _initialCategoriesSelectedValid.sink
        .add(_initialCategories.reduce((a, b) => a || b));
    _initialCategoriesSelected.sink.add(_initialCategories);
  }

  void showNoCategoriesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        bool submitted = false;
        List<String> items = [
          'Rent',
          'Water',
          'Electricity',
          'Gas',
          'Garbage',
          'Internet'
        ];

        return Dialog(
          child: Padding(
            padding: Style.eventsViewPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Welcome to ${currentAccount.accountName}',
                  style: Style.subTitleTextStyle,
                ),
                Container(height: 10.0),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Select any expense categories that are appropriate for this group. Every bill needs a category, so there must be at least one category before you can enter a bill.',
                      style: Style.regularTextStyle,
                    ),
                    Container(height: 10.0),
                    Container(
                      child: StreamBuilder<List<bool>>(
                        stream: _initialCategoriesSelected.stream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Container();
                          return SEGridView(
                            itemCount: 6,
                            itemBuilder: (context, i) => GridTile(
                              child: InkWell(
                                onTap: () => _toggleNewCategorySelected(i),
                                child: Container(
                                  color: snapshot.data[i]
                                      ? Colors.lightBlue.shade200
                                      : null,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Checkbox(
                                          value: snapshot.data[i],
                                          onChanged: null,
                                        ),
                                        Text(
                                          items[i],
                                          style: Style.tinyTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(height: 10.0),
                    Text(
                      'You can modify this list or create your own categories in the account management page at any time.',
                      style: Style.regularTextStyle,
                    ),
                    Container(height: 10.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FloatingActionButton(
                          heroTag: 'dummy_btn',
                          child: Icon(
                            Icons.apps,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.orange,
                          onPressed: () => null,
                        ),
                        Container(width: 10.0),
                        Expanded(
                          child: Text(
                            'The orange button in the bottom right opens the account management page.',
                            style: Style.regularTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                StreamBuilder<bool>(
                  stream: _initialCategoriesSelectedValid.stream,
                  builder: (context, snapshot) {
                    return FlatButton(
                      child: Text(!submitted ? 'Submit' : 'Submitting ...'),
                      onPressed: (snapshot.hasData && snapshot.data)
                          ? () async {
                              if (!submitted) {
                                submitted = true;
                                for (int i = 0; i < items.length; i++) {
                                  if (_initialCategories[i]) {
                                    await repo.addBillType(
                                        currentAccount.accountId, items[i]);
                                  }
                                }
                                dispose();
                                return Navigator.pop(context);
                              }
                            }
                          : null,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void dispose() {
    _initialCategoriesSelected.close();
    _initialCategoriesSelectedValid.close();
  }
}
