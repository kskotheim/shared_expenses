import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'bloc_provider.dart';

class AuthBloc implements BlocBase {
  
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
    _authEventSink.add(CreateAccountEvent(username: username, password: password));
  }

  //firebase auth instance
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
    if(event is CreateAccountEvent){
      _createAccount(event);
    }
  }

  void _start() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    _checkUserAndLogIn(user);
  }

  void _login(LoginEvent event) async {
    _authStateSink.add(AuthStateLoading());
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: event.username, password: event.password);
    _checkUserAndLogIn(user);
  }

  void _logout() {
    _firebaseAuth.signOut();
    _authStateSink.add(AuthStateNotLoggedIn());
  }
  
  void _createAccount(CreateAccountEvent event) async {
    _authStateSink.add(AuthStateLoading());
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: event.username, password: event.password);
    _checkUserAndLogIn(user);
  }

  void _checkUserAndLogIn(FirebaseUser user) {
    if(user == null) _authStateSink.add(AuthStateNotLoggedIn());
    else _authStateSink.add(AuthStateLoggedIn(username: user.email));
  }

  
  @override
  void dispose() {
    _authController.close();
    _authInputController.close();
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
