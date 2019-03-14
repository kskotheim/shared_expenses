import 'dart:async';
import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/user.dart';

class AccountBloc implements BlocBase {
  final AuthBloc authBloc;
  final Repository repo = Repository();

  User currentUser;
  Map<String, String> accountNames;

  StreamController<AccountState> _accountStateController =StreamController<AccountState>();
  Stream<AccountState> get accountState => _accountStateController.stream;
  StreamSink get _accountStateSink => _accountStateController.sink;

  StreamController<AccountEvent> _accountEventController =StreamController<AccountEvent>();
  StreamSink get accountEvent => _accountEventController.sink;

  AccountBloc({this.authBloc}) {
    assert(authBloc != null);
    _accountEventController.stream.listen(_mapEventToState);
    _getUserAccount();
  }

  void _mapEventToState(AccountEvent event) {
    if (event is AccountEventCreateAccount) {}
    if (event is AccountEventRenameUser) {}
    if (event is AccountEventGoHome) {}
    if (event is AccountEventGoToSelect) {}
  }

  @override
  void dispose() {
    _accountStateController.close();
    _accountEventController.close();
  }

  void _getUserAccount() async {
    _accountStateSink.add(AccountStateLoading());

    currentUser = await repo.getUserFromDb(authBloc.currentUserId);

    accountNames = await repo.getAccountNames(currentUser.accounts);

    if(currentUser.accounts.length == 1){
      //Set up account info
      _accountStateSink.add(AccountStateHome());
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

class AccountEventCreateAccount extends AccountEvent {}

class AccountEventRenameUser extends AccountEvent {}