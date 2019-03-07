import 'dart:async';
import 'package:shared_expenses/src/resources/auth.dart';

import 'bloc_provider.dart';

class AuthBloc implements BlocBase {
  
  //bloc output
  StreamController<AuthState> _authorizedStream =StreamController<AuthState>();
  Stream<AuthState> get authStream => _authorizedStream.stream;
  StreamSink get _authSink => _authorizedStream.sink;

  //bloc input
  StreamController<AuthEvent> _authorizedEventStream =StreamController<AuthEvent>(); 
  StreamSink get _authEvent =>_authorizedEventStream.sink;

  //public methods:
  //add login event to stream
  void login(String username, String password){
    _authEvent.add(LoginEvent(username: username, password: password));
  }
  //add logout event to stream
  void logout(){
    _authEvent.add(LogoutEvent());
  }
  //create new acct
  void createAcct(String username, String password){
    _authEvent.add(CreateAccountEvent(username: username, password: password));
  }

  //google auth instance
  Auth _auth = Auth();

  AuthBloc(){
    _authorizedEventStream.stream.listen(_mapEventToState);
    _authEvent.add(AppStartEvent());
  }

  void _mapEventToState(AuthEvent event) async { 
    if(event is AppStartEvent){
      _authSink.add(AuthStateLoading());
      var user = await _auth.currentUser();
      if(user == null) _authSink.add(AuthStateNotLoggedIn());
      else _authSink.add(AuthStateLoggedIn(username: user.email));
    }
    if(event is LoginEvent){
      _authSink.add(AuthStateLoading());
      var user = await _auth.signInWithEmailAndPassword(event.username, event.password);
      if(user == null) _authSink.add(AuthStateNotLoggedIn());
      else _authSink.add(AuthStateLoggedIn(username: event.username));
    }
    if(event is LogoutEvent){
      _authSink.add(AuthStateNotLoggedIn());
    }
    if(event is CreateAccountEvent){
      _authSink.add(AuthStateLoading());
      var user = await _auth.createUser(event.username, event.password);
      if(user == null) _authSink.add(AuthStateNotLoggedIn());
      else _authSink.add(AuthStateLoggedIn(username: event.username));
    }
  }

  
  @override
  void dispose() {
    _authorizedStream.close();
    _authorizedEventStream.close();
  }


}

class AuthState{
  final String username = 'not logged in';
}

//Authorization State - Bloc output
class AuthStateNotLoggedIn extends AuthState{}

class AuthStateLoading extends AuthState {}

class AuthStateLoggedIn extends AuthState{
  final String username;
  AuthStateLoggedIn({this.username}) : assert(username != null);
}

//Authorization Event - Bloc Input
class AuthEvent {}

class AppStartEvent extends AuthEvent {}

class LoginEvent extends AuthEvent{
  final String username;
  final String password;

  LoginEvent({this.username, this.password}) : assert(username != null, password != null);
}
class CreateAccountEvent extends AuthEvent{
  final String username;
  final String password;

  CreateAccountEvent({this.username, this.password}) : assert(username != null, password != null);
}

class LogoutEvent extends AuthEvent{}
