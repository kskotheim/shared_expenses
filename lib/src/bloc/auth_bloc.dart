import 'dart:async';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/models/user.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';


class AuthBloc implements BlocBase {

  final Repository repo = Repository();
  User currentUser;

  //bloc output
  BehaviorSubject<AuthState> _authController =BehaviorSubject<AuthState>.seeded(AuthStateLoading());
  Stream<AuthState> get authStream => _authController.stream;
  StreamSink get _authStateSink => _authController.sink;

  //bloc input
  StreamController<AuthEvent> _authInputController =StreamController<AuthEvent>(); 
  StreamSink get _authEventSink =>_authInputController.sink;

  //public methods:
  void login(String username, String password){
    _authEventSink.add(LoginEvent(username: username, password: password));
  }
  void logout(){
    _authEventSink.add(LogoutEvent());
  }
  void createAcct(String username, String password){
    _authEventSink.add(CreateUserEvent(username: username, password: password));
  }
  void error(String error){
    _errorLoggingIn(error);
  }

  //login state
  bool _creatingNewAccount = false;
  bool get creatingNewAccount => _creatingNewAccount;
  void goToCreateAccount() => _creatingNewAccount = !_creatingNewAccount;

  AuthBloc(){
    _authEventSink.add(AppStartEvent());
    _authInputController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(AuthEvent event) async { 
    if(event is AppStartEvent){
      _start();
    }
    if(event is LoginEvent){
      _login(event);
    }
    if(event is LogoutEvent){
      _logout();
    }
    if(event is CreateUserEvent){
      _createUser(event);
    }
  }

  void _start() async {
    currentUser = await repo.currentUser();
    if(currentUser == null) _errorLoggingIn('Please Create an Account or Log in');
    else _logInUser(currentUser);
  }

  void _login(LoginEvent event) async {
    _authStateSink.add(AuthStateLoading());
    String error;
    User user = await repo.signInWithEmailAndPassword(event.username, event.password)
    .catchError((e) { error = _catchError(e);});
    
    if(error != null){
      _errorLoggingIn(error);
    } else _logInUser(user);
  }

  void _logout() {
    repo.signOut();
    _authStateSink.add(AuthStateNotLoggedIn());
  }
  
  void _createUser(CreateUserEvent event) async {
    _authStateSink.add(AuthStateLoading());
    String error;
    User user = await repo.createUserWithEmailAndPassword(event.username, event.password)
    .catchError((e) { error = _catchError(e);});
    
    await repo.createUser(user.userId);
 
    if(error != null){
      _errorLoggingIn(error);
    } else {
      _logInUser(user);
    }
  }

  void _logInUser(User user) {
    _authStateSink.add(AuthStateLoggedIn());
  }

  void _errorLoggingIn(String error) {
    _authStateSink.add(AuthStateNotLoggedIn(error: error));
  }

  String _catchError(e) {
    if(e is PlatformException){
      return e.message;
    } else return e.toString();
  }

  @override
  void dispose() {
    _authController.close();
    _authInputController.close();
  }
}

//Authorization State - Bloc output
class AuthState{}

class AuthStateNotLoggedIn extends AuthState{
  final String error;
  AuthStateNotLoggedIn({this.error});
}

class AuthStateLoading extends AuthState {}

class AuthStateLoggedIn extends AuthState{}

//Authorization Event - Bloc Input
class AuthEvent {}

class AppStartEvent extends AuthEvent {}

class LoginEvent extends AuthEvent{
  final String username;
  final String password;

  LoginEvent({this.username, this.password}) : assert(username != null, password != null);
}

class CreateUserEvent extends AuthEvent{
  final String username;
  final String password;

  CreateUserEvent({this.username, this.password}) : assert(username != null, password != null);
}

class LogoutEvent extends AuthEvent{}