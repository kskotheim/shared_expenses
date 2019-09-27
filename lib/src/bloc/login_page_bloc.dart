import 'dart:async';
import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:rxdart/rxdart.dart';

class LoginPageBloc implements BlocBase {
  final AuthBloc authBloc;

  static String _currentUserName = '';
  static bool _currentUserNameOk = false;
  static String _currentPassword = '';
  static bool _currentPasswordOk = false;
  static bool _currentVerifiedPasswordOk = false;

  StreamController<String> _emailStringController = StreamController<String>();
  Stream<String> get email => _emailStringController.stream.transform(_emailValidator);
  Function(String) get changeName => _emailStringController.add;

  StreamController<String> _passwordStringController = StreamController<String>();
  Stream<String> get password => _passwordStringController.stream.transform(_passwordValidator);
  Function(String) get changePassword => _passwordStringController.add;

  StreamController<String> _verifiedPasswordStringController = StreamController<String>.broadcast();
  Stream<String> get verifiedPassword => _verifiedPasswordStringController.stream.transform(_verifiedPasswordValidator);
  Function(String) get changeverifiedPassword => _verifiedPasswordStringController.add;

  BehaviorSubject<LoginPageState> _loginPageStateStreamController = BehaviorSubject<LoginPageState>();
  Stream<LoginPageState> get loginPageState => _loginPageStateStreamController.stream;
  StreamSink get _loginPageStateSink => _loginPageStateStreamController.sink;

  StreamController<LoginPageEvent> _loginPageEventStreamController = StreamController<LoginPageEvent>();
  StreamSink get loginPageEventSink => _loginPageEventStreamController.sink;

  LoginPageBloc({this.authBloc}){
    assert(authBloc != null);
    _loginPageEventStreamController.stream.listen(_mapEventToState);
    _loginPageStateSink.add(authBloc.creatingNewAccount ? ShowCreateAccountPage() : ShowLoginPage());
  }

  void _mapEventToState(LoginPageEvent event){
    if(event is LoginButtonPressed){
      _handleLoginOrCreateAccount();
    }
    if (event is SwitchToCreateAccountButtonPressed){
      _switchToCreateAccountOrLogin();
    }
  }

  void _handleLoginOrCreateAccount() {
    if(_currentUserNameOk && _currentPasswordOk && (!authBloc.creatingNewAccount || _currentVerifiedPasswordOk))
      {
        if(authBloc.creatingNewAccount) authBloc.createAcct(_currentUserName, _currentPassword);
        else authBloc.login(_currentUserName, _currentPassword);
      } else {
        if(!_currentUserNameOk)
          authBloc.error('invalid email');
        else if(!_currentPasswordOk)
          authBloc.error('password must be at least 6 characters');
        else if(authBloc.creatingNewAccount && !_currentVerifiedPasswordOk)
          authBloc.error('passwords must match');
      }
  }

  void _switchToCreateAccountOrLogin() {
    authBloc.goToCreateAccount();
    _loginPageStateSink.add(authBloc.creatingNewAccount ? ShowCreateAccountPage() : ShowLoginPage());
  }


  final _emailValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) async {
      if(_isEmail(email)){
        _currentUserNameOk = true;
        _currentUserName = email;
        sink.add(email);
      }
      else{
        sink.addError('you@example.com');
        _currentUserNameOk = false;
      }
    }
  );

  static bool _isEmail(String email){
    Pattern pattern = r"""^(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$""";
    RegExp regex = new RegExp(pattern);
    if (regex.hasMatch(email)) return true;
    else return false;
  }

  final _passwordValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink){
      if(password.length > 5){
        _currentPasswordOk = true;
        _currentPassword = password;
        sink.add(password);
      }
      else{
        sink.addError('at least 6 characters');
        _currentPasswordOk = false;
      }
    }
  );

  final _verifiedPasswordValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink){
      if(password ==_currentPassword){
        _currentVerifiedPasswordOk = true;
        sink.add(password);
      }
      else{
        sink.addError('passwords must match');
        _currentVerifiedPasswordOk = false;
      }
    }
  );

  @override
  void dispose() {
    _emailStringController.close();
    _verifiedPasswordStringController.close();
    _passwordStringController.close();
    _loginPageEventStreamController.close();
    _loginPageStateStreamController.close();
  }
  
}

class LoginPageEvent{}

class SwitchToCreateAccountButtonPressed extends LoginPageEvent{}

class LoginButtonPressed extends LoginPageEvent{}

class LoginPageState{}

class ShowLoginPage extends LoginPageState{}

class ShowCreateAccountPage extends LoginPageState{}