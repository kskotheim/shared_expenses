import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:collection/collection.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/account.dart';
import 'package:shared_expenses/src/res/models/event.dart';
import 'package:shared_expenses/src/res/models/user.dart';

// This class manages account logic like whether the user is logged in and the main account page should be shown
// It is primarily utilized at the level of the account page

class AccountBloc implements BlocBase {
  final AuthBloc authBloc;
  final Repository repo = Repository.getRepo;

  //User info
  User currentUser;
  List<Account> groups;
  Account groupById(String id) => groups.singleWhere((group) => group.accountId == id);
  List<String> get currentUserGroupIds => groups?.map((account) => account.accountId)?.toList();

  StreamController<PageToDisplay> _accountStateController =StreamController<PageToDisplay>();
  Stream<PageToDisplay> get accountState => _accountStateController.stream;
  StreamSink get _accountStateSink => _accountStateController.sink;

  // controls which page  display
  StreamController<AccountStateEvent> _accountEventController =StreamController<AccountStateEvent>();
  StreamSink get accountEvent => _accountEventController.sink;

  AccountBloc({this.authBloc}) {
    assert(authBloc != null);
    _accountEventController.stream.listen(_mapEventToState);
    _setUpAccount();

  }

  Future<void> _setUpAccount() async {
    //get the current user and the groups that user is registered with
    currentUser = await repo.getUserFromDb(authBloc.currentUserId);
    repo.userGroupsSubscription(authBloc.currentUserId).listen(_setAccounts);
    repo.currentUserStream(currentUser.userId).listen(_recieveUserInfo);
  }

  void _recieveUserInfo(User user){
    if(currentUser != user){
      currentUser = user;
      _goToAccountsOrSelect();
    }
  }

  void _setAccounts(List<Account> accounts) async {
    Function equals = DeepCollectionEquality.unordered().equals;
    List<String> newAccountIds = accounts.map((account) =>account.accountId).toList();
    if(!equals(currentUserGroupIds, newAccountIds)){
      // wait a few seconds to avoid firestoer permissions errors
      await Future.delayed(Duration(seconds: 2));
      groups = accounts;
      _goToAccountsOrSelect();
    }
  }

  void _mapEventToState(AccountStateEvent event) {
    if (event is AccountEventGoHome) {
      _goHome(event.accountId);
    }
    if (event is AccountEventGoToSelect) {
      _goToSelect();
    }
    if (event is AccountEventCreateAccount) {
      _createAccount(event.accountName);
    }
    if (event is AccountEventRenameUser) {
      _renameUser(event.newName);
    }
    
    if(event is AccountEventSendConnectionRequest){
      _requestConnection(event.accountName);
    }
  }


  void _goHome(String accountId) {
    _accountStateSink.add(DisplayGroupPage(groupId: accountId));
  }

  void _goToSelect() {
    _accountStateSink.add(DisplaySelectAccountPage());
  }

  void _createAccount(String accountName) async {
    if(accountName.length > 0){
      _accountStateSink.add(DisplayLoadingPage());
      dynamic accountIdOrNull = await repo.getGroupByName(accountName);

      if(accountIdOrNull == null) {
        repo.createGroup(accountName, currentUser);
      } else {
        _accountStateSink.add(DisplaySelectAccountPage(error: '$accountName already exists')); 
      }
    }
  }

  void _renameUser(String username){
    if(username !=currentUser.userName){
      _accountStateSink.add(DisplayLoadingPage());
      String oldUsername = currentUser.userName;
      repo.updateUserName(currentUser.userId, username);
      currentUserGroupIds.forEach((group){
        //add account event to group of name change
        repo.createAccountEvent(group, AccountEvent(userId: currentUser.userId, actionTaken: 'changed name from $oldUsername to $username'));
      });
    }
  }

  void _requestConnection(String accountName) async {
    _accountStateSink.add(DisplayLoadingPage());
    dynamic accountIdOrNull = await repo.getGroupByName(accountName);
    
    if(accountIdOrNull != null){
      bool newAccount = !currentUserGroupIds.contains(accountIdOrNull);
    
      if(newAccount){
        repo.createAccountConnectionRequest(accountIdOrNull, currentUser.userId);
      } else {
        _accountStateSink.add(DisplaySelectAccountPage(error: 'You are already connected to $accountName'));
      }
    } else {
      _accountStateSink.add(DisplaySelectAccountPage(error: '$accountName does not exist'));
    }
  }

  void _goToAccountsOrSelect() {
    if(groups != null && currentUser != null){
      if(currentUserGroupIds.length == 1){
        accountEvent.add(AccountEventGoHome(accountId: currentUserGroupIds[0]));
      } else {
        accountEvent.add(AccountEventGoToSelect());
      }
    }
  }

  void deleteGroup(String groupId){
    repo.deleteGroup(groupId);
  }

  @override
  void dispose() {
    _accountStateController.close();
    _accountEventController.close();

  }
}

// output types

class PageToDisplay {}

class DisplayLoadingPage extends PageToDisplay {}

class DisplaySelectAccountPage extends PageToDisplay {
  final String error;
  DisplaySelectAccountPage({this.error});
}

class DisplayGroupPage extends PageToDisplay {
  final String groupId;
  DisplayGroupPage({this.groupId}) : assert(groupId != null);
}

// input types

class AccountStateEvent {}

class AccountEventGoToSelect extends AccountStateEvent {}

class AccountEventGoHome extends AccountStateEvent {
  final String accountId;
  AccountEventGoHome({this.accountId});
}

class AccountEventCreateAccount extends AccountStateEvent {
  final String accountName;
  AccountEventCreateAccount({this.accountName});
}

class AccountEventRenameUser extends AccountStateEvent {
  final String newName;
  AccountEventRenameUser({this.newName}) : assert(newName != null);
}

class AccountEventSendConnectionRequest extends AccountStateEvent {
  final String accountName;
  AccountEventSendConnectionRequest({this.accountName}) : assert(accountName != null);
}
