import 'dart:async';

import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';

import 'package:shared_expenses/src/data/repository.dart';

import 'package:shared_expenses/src/res/db_strings.dart';
import 'package:shared_expenses/src/res/models/account.dart';
import 'package:shared_expenses/src/res/models/user.dart';

class AccountBloc implements BlocBase {
  final AuthBloc authBloc;
  final Repository repo = Repository.getRepo;

  //User info
  User currentUser;
  Map<String, String> accountNames;

  //Account info
  Account currentAccount;
  List<User> usersInAccount;
  List<String> permissions;

  String userName(String userId){
    if(usersInAccount != null){
    User user = usersInAccount.where((user) => user.userId == userId).toList().removeLast();
    if(user != null) return user.userName;
    else return 'no user by that id';
    } else return 'loading ...';
  }

  StreamController<AccountState> _accountStateController =StreamController<AccountState>();
  Stream<AccountState> get accountState => _accountStateController.stream;
  StreamSink get _accountStateSink => _accountStateController.sink;

  StreamController<AccountEvent> _accountEventController =StreamController<AccountEvent>();
  StreamSink get accountEvent => _accountEventController.sink;

  StreamController<List<User>> _usersInAccountController = StreamController<List<User>>.broadcast();
  Stream<List<User>> get usersInAccountStream => _usersInAccountController.stream;
  StreamSink get _usersInAccountSink => _usersInAccountController.sink;

  StreamSubscription _usersInAccountSubscription;
  StreamSubscription _userSubscription;
  StreamSubscription _accountSubscription;

  AccountBloc({this.authBloc}) {
    assert(authBloc != null);
    _accountSubscription =  _accountEventController.stream.listen(_mapEventToState);
    _userSubscription = repo.currentUserStream(authBloc.currentUserId).listen(_updateCurrentUserAndAccountNames);
    usersInAccountStream.listen((List<User> users) => usersInAccount = users);
  }

  void _mapEventToState(AccountEvent event) {
    if (event is AccountEventGoHome) {
      _goHome(event.accountIndex);
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

  void _goHome(int accountIndex) {
    String accountId = currentUser.accounts[accountIndex];
    currentAccount = Account(accountId: accountId, accountName: accountNames[accountId]);
    permissions =  List<String>.from(currentUser.accountInfo[currentAccount.accountId][PERMISSIONS]);
    _usersInAccountSubscription = repo.userStream(accountId).listen(_setAccountUsers);
    
    _accountStateSink.add(AccountStateHome());
  }

  void _setAccountUsers(List<User> users){
    _usersInAccountSink.add(users);
  }

  void _goToSelect() {
    currentAccount = null;
    _usersInAccountSink.add(<User>[]);
    permissions = null;
    _accountStateSink.add(AccountStateSelect());
  }

  void _createAccount(String accountName) async {
    _accountStateSink.add(AccountStateLoading());
    dynamic accountIdOrNull = await repo.getAccountByName(accountName);

    if(accountIdOrNull == null) {
      repo.createAccount(accountName, currentUser);
    } else {
      _accountStateSink.add(AccountStateSelect(error: '$accountName already exists')); 
    }
  }

  void _renameUser(String username){
    if(username !=currentUser.userName){
      _accountStateSink.add(AccountStateLoading());
      repo.updateUserName(currentUser.userId, username);
    }
  }

  void _requestConnection(String accountName) async {
    _accountStateSink.add(AccountStateLoading());
    dynamic accountIdOrNull = await repo.getAccountByName(accountName);
    
    if(accountIdOrNull != null){
      bool newAccount = !currentUser.accounts.contains(accountIdOrNull);
    
      if(newAccount){
        repo.createAccountConnectionRequest(accountIdOrNull, currentUser.userId);
      } else {
        _accountStateSink.add(AccountStateSelect(error: 'You are already connected to $accountName'));
      }
    } else {
      _accountStateSink.add(AccountStateSelect(error: '$accountName does not exist'));
    }
  }

  void _goToAccountsOrSelect() {
    if(currentUser.accounts.length == 1){
      accountEvent.add(AccountEventGoHome(accountIndex: 0));
    } else {
      accountEvent.add(AccountEventGoToSelect());
    }
  }

  void _updateCurrentUserAndAccountNames(User user) async{
    //check to see if we need to update accountNames
    if(currentUser != null){
      if(currentUser.accounts != user.accounts){
        accountNames = await repo.getAccountNames(user.accounts);
      } //otherwise they are still accurate
    } else { //no current user, so we need names from this one
      accountNames = await repo.getAccountNames(user.accounts);
    }
    currentUser = user;

    _goToAccountsOrSelect();
  }


  @override
  void dispose() {
    _accountStateController.close();
    _accountEventController.close();
    _usersInAccountController.close();
    _userSubscription.cancel();
    _accountSubscription.cancel();
    _usersInAccountSubscription.cancel();
  }
}

class AccountState {}

class AccountStateLoading extends AccountState {}

class AccountStateSelect extends AccountState {
  final String error;
  AccountStateSelect({this.error});
}

class AccountStateHome extends AccountState {}

class AccountEvent {}

class AccountEventGoToSelect extends AccountEvent {}

class AccountEventGoHome extends AccountEvent {
  final int accountIndex;
  AccountEventGoHome({this.accountIndex});
}

class AccountEventCreateAccount extends AccountEvent {
  final String accountName;
  AccountEventCreateAccount({this.accountName});
}

class AccountEventRenameUser extends AccountEvent {
  final String newName;
  AccountEventRenameUser({this.newName}) : assert(newName != null);
}

class AccountEventSendConnectionRequest extends AccountEvent {
  final String accountName;
  AccountEventSendConnectionRequest({this.accountName}) : assert(accountName != null);
}
