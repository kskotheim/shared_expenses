import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/account.dart';
import 'package:shared_expenses/src/res/models/user.dart';

class AccountBloc implements BlocBase {
  final AuthBloc authBloc;
  final Repository repo = Repository.getRepo;

  User currentUser;
  Account currentAccount;
  Map<String, String> accountNames;

  StreamController<AccountState> _accountStateController =StreamController<AccountState>();
  Stream<AccountState> get accountState => _accountStateController.stream;
  StreamSink get _accountStateSink => _accountStateController.sink;

  StreamController<AccountEvent> _accountEventController =StreamController<AccountEvent>();
  StreamSink get accountEvent => _accountEventController.sink;

  StreamSubscription _userSubscription;
  BehaviorSubject<User> _currentUserController = BehaviorSubject<User>();
  Stream<User> get currentUserStream => _currentUserController.stream;
  

  AccountBloc({this.authBloc}) {
    print('created a new accountBloc');
    assert(authBloc != null);
    _userSubscription = repo.currentUserStream(authBloc.currentUserId).listen(_updateUserInfo);
    _accountEventController.stream.listen(_mapEventToState);
    _getUserAccounts();
  }

  void _mapEventToState(AccountEvent event) {
    if (event is AccountEventCreateAccount) {
      _createAccount(event.accountName);
    }
    if (event is AccountEventRenameUser) {
      _renameUser(event.newName);
    }
    if (event is AccountEventGoHome) {
      String accountId = currentUser.accounts[event.accountIndex];
      currentAccount = Account(accountId: accountId, accountName: accountNames[accountId]);
      _accountStateSink.add(AccountStateHome());
    }
    if (event is AccountEventGoToSelect) {
      _accountStateSink.add(AccountStateSelect());
    }
    if(event is AccountEventSendConnectionRequest){
      _requestConnection(event.accountName);
    }
  }

  void _updateUserInfo(DocumentSnapshot snapshot) async{
    if(snapshot.data == null) return print('no data in user snapshot');
    User newUser = User.fromDocumentSnapshot(snapshot);
    currentUser = newUser;
    accountNames = await repo.getAccountNames(currentUser.accounts);
    _currentUserController.sink.add(currentUser);
  }

  @override
  void dispose() {
    _accountStateController.close();
    _accountEventController.close();
    _currentUserController.close();
    _userSubscription.cancel();
  }

  void _requestConnection(String accountName) async {
    print('requesting connection');
    _accountStateSink.add(AccountStateLoading());
    dynamic accountIdOrNull = await repo.getAccountByName(accountName);
    
    if(accountIdOrNull == null){ 
      return _accountStateSink.add(AccountStateSelect(error: '$accountName does not exist'));
    }

    repo.createAccountConnectionRequest(accountIdOrNull, currentUser.userId);
    _accountStateSink.add(AccountStateSelect());
  }

  dynamic _createAccount(String accountName) async {
    _accountStateSink.add(AccountStateLoading());
    bool nameExists = await repo.doesAccountNameExist(accountName);
    if(nameExists) {
      return _accountStateSink.add(AccountStateSelect(error: '$accountName already exists')); 
    }
    
    //do we actually need this id here?
    String accountId = await repo.createAccount(accountName, currentUser.userId);

    _getUserAccounts();
  }

  void _renameUser(String username){
      _accountStateSink.add(AccountStateLoading());
      repo.updateUserName(currentUser.userId, username).then(
        (_) => repo.getUserFromDb(currentUser.userId)
      ).then(
        (user) {
          currentUser = user;
          _accountStateSink.add(AccountStateSelect());
        });
  }

  void _getUserAccounts() async {
    _accountStateSink.add(AccountStateLoading());

    print('authBloc.currentUserId: ${authBloc.currentUserId}');
    currentUser = await repo.getUserFromDb(authBloc.currentUserId);
    if(currentUser == null) authBloc.logout();

    accountNames = await repo.getAccountNames(currentUser.accounts);

    if(currentUser.accounts.length == 1){
      //Set up account info
      accountEvent.add(AccountEventGoHome(accountIndex: 0));
    }
    else {
      //else, show select/create accounts page
      _accountStateSink.add(AccountStateSelect());
    }
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
