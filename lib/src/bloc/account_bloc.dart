import 'dart:async';
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

  StreamController _accountNameErrorController = StreamController.broadcast();
  Stream get accountNameErrors => _accountNameErrorController.stream;

  AccountBloc({this.authBloc}) {
    assert(authBloc != null);
    _accountEventController.stream.listen(_mapEventToState);
    _getUserAccount();
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
      repo.setAccountId(currentAccount.accountId);
      _accountStateSink.add(AccountStateHome());
    }
    if (event is AccountEventGoToSelect) {
      _accountStateSink.add(AccountStateSelect());
    }
  }

  @override
  void dispose() {
    _accountStateController.close();
    _accountEventController.close();
    _accountNameErrorController.close();
  }

  dynamic _createAccount(String accountName) async {
    bool nameExists = await repo.doesAccountNameExist(accountName);
    if(nameExists) {
      _accountNameErrorController.sink.addError('$accountName already exists');
      return _accountStateSink.add(AccountStateSelect()); 
    }
    
    String accountId = await repo.createAccount(accountName);
    await repo.addAccountIdToUser(currentUser.userId, accountId);
    //make this user the owner of the account
    _getUserAccount();


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

  void _getUserAccount() async {
    _accountStateSink.add(AccountStateLoading());

    currentUser = await repo.getUserFromDb(authBloc.currentUserId);

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

class AccountStateSelect extends AccountState {}

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
