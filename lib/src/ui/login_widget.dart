import 'package:flutter/material.dart';

import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/login_page_bloc.dart';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  AuthBloc _authBloc;
  LoginPageBloc _loginPageBloc;

  //local state variables managed in this class
  static bool obscurePasswordText = true;
  static bool creatingNewAccount = false;

  @override
  Widget build(BuildContext context) {
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _loginPageBloc = LoginPageBloc();

    LoginField _nameField = LoginField(hint: 'email', onChanged: _loginPageBloc.changeName, stream: _loginPageBloc.email,);
    LoginField _passwordField = LoginField(obscureText: obscurePasswordText, hint: 'password', onChanged:_loginPageBloc.changePassword, stream: _loginPageBloc.password,);
    LoginField _secondPasswordField = LoginField(obscureText: obscurePasswordText, hint: 'verify password', onChanged: _loginPageBloc.changeverifiedPassword,stream: _loginPageBloc.verifiedPassword,);
        
    return BlocProvider(
      bloc: _loginPageBloc,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _nameField,
            _passwordField,
            creatingNewAccount ? _secondPasswordField : Container(),
            Container(height: 40),
            RaisedButton(
              onPressed: () {
                if(!_loginPageBloc.currentUserNameOk) _authBloc.error('Invalid username');
                else if(!_loginPageBloc.currentPasswordOk) _authBloc.error('Password must be at least 6 characters');
                else if(creatingNewAccount && !_loginPageBloc.currentVerifiedPasswordOk) _authBloc.error('Passwords must match');
                else if (creatingNewAccount) {
                    _authBloc.createAcct(_loginPageBloc.currentUserName, _loginPageBloc.currentPassword);
                } else
                  _authBloc.login(_loginPageBloc.currentUserName, _loginPageBloc.currentPassword);
              },
              child: Text(creatingNewAccount ? 'Create Account' : 'Login'),
            ),
            RaisedButton(
              child: Text(
                  creatingNewAccount ? 'Go to Login' : 'Go to Create Account'),
              onPressed: () {
                setState(() {
                  creatingNewAccount = !creatingNewAccount;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LoginField extends StatelessWidget {
  bool obscureText;
  String hint;
  Function(String) onChanged;
  Stream stream;

  LoginField({this.obscureText, this.hint,this.onChanged, this.stream}) {
    if (obscureText == null) obscureText = false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: stream,
      builder: (context, snapshot) {
        return Container(
          width: 200.0,
          child: TextField(
            onChanged: onChanged,
            obscureText: obscureText,
            decoration: InputDecoration(hintText: hint, errorText: snapshot.error),
          ),
        );
      }
    );
  }
}
