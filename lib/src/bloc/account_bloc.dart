import 'dart:async';
import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';

import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/event.dart';
import 'package:shared_expenses/src/res/models/user.dart';

class AccountBloc implements BlocBase {
  final AuthBloc authBloc;
  final Repository repo = Repository.getRepo;

  //User info
  User currentUser;
  Map<String, String> accountNames;

  StreamController<PageToDisplay> _accountStateController =StreamController<PageToDisplay>();
  Stream<PageToDisplay> get accountState => _accountStateController.stream;
  StreamSink get _accountStateSink => _accountStateController.sink;

  StreamController<AccountStateEvent> _accountEventController =StreamController<AccountStateEvent>();
  StreamSink get accountEvent => _accountEventController.sink;

  
  StreamSubscription _userSubscription;
  StreamSubscription _accountSubscription;

  AccountBloc({this.authBloc}) {
    assert(authBloc != null);
    _accountSubscription =  _accountEventController.stream.listen(_mapEventToState);
    _userSubscription = repo.currentUserStream(authBloc.currentUserId).listen(_updateCurrentUserAndAccountNames);
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
    _accountStateSink.add(DisplayLoadingPage());
    dynamic accountIdOrNull = await repo.getAccountByName(accountName);

    if(accountIdOrNull == null) {
      repo.createAccount(accountName, currentUser);
    } else {
      _accountStateSink.add(DisplaySelectAccountPage(error: '$accountName already exists')); 
    }
  }

  void _renameUser(String username){
    if(username !=currentUser.userName){
      _accountStateSink.add(DisplayLoadingPage());
      String oldUsername = currentUser.userName;
      repo.updateUserName(currentUser.userId, username);
      currentUser.groups.forEach((group){
        //add account event to group of name change
        repo.createAccountEvent(group, AccountEvent(userId: currentUser.userId, actionTaken: 'changed name from $oldUsername to $username'));
      });
    }
  }

  void _requestConnection(String accountName) async {
    _accountStateSink.add(DisplayLoadingPage());
    dynamic accountIdOrNull = await repo.getAccountByName(accountName);
    
    if(accountIdOrNull != null){
      bool newAccount = !currentUser.groups.contains(accountIdOrNull);
    
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
    if(currentUser.groups.length == 1){
      accountEvent.add(AccountEventGoHome(accountId: currentUser.groups[0]));
    } else {
      accountEvent.add(AccountEventGoToSelect());
    }
  }

  void _updateCurrentUserAndAccountNames(User user) async{
    //check to see if we need to update accountNames
    if(currentUser != null){
      if(currentUser.groups != user.groups){
        accountNames = await repo.getAccountNames(user.groups);
      } //otherwise they are still accurate
    } else { //no current user, so we need names from this one
      accountNames = await repo.getAccountNames(user.groups);
    }
    currentUser = user;

    _goToAccountsOrSelect();
  }


  @override
  void dispose() {
    _accountStateController.close();
    _accountEventController.close();
    _userSubscription.cancel();
    _accountSubscription.cancel();

  }
}

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
