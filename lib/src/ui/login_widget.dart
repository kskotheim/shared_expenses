import 'package:flutter/material.dart';

import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/login_page_bloc.dart';

class LoginWidget extends StatelessWidget {
  AuthBloc _authBloc;
  LoginPageBloc _loginPageBloc;

  @override
  Widget build(BuildContext context) {
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _loginPageBloc = LoginPageBloc(authBloc: _authBloc);

    LoginField _nameField = LoginField(
      hint: 'email',
      onChanged: _loginPageBloc.changeName,
      stream: _loginPageBloc.email,
    );
    LoginField _passwordField = LoginField(
      obscureText: true,
      hint: 'password',
      onChanged: _loginPageBloc.changePassword,
      stream: _loginPageBloc.password,
    );
    LoginField _secondPasswordField = LoginField(
      obscureText: true,
      hint: 'verify password',
      onChanged: _loginPageBloc.changeverifiedPassword,
      stream: _loginPageBloc.verifiedPassword,
    );

    return BlocProvider(
      bloc: _loginPageBloc,
      child: StreamBuilder<Object>(
          stream: _loginPageBloc.loginPageState,
          builder: (context, snapshot) {
            if (snapshot.data == null) return Text('no data in login field');

            bool creatingNewAccount = snapshot.data is ShowCreateAccountPage;
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _nameField,
                    _passwordField,
                    creatingNewAccount ? _secondPasswordField : Container(),
                    Container(height: 40),
                    RaisedButton(
                      onPressed: () {
                        _loginPageBloc.loginPageEventSink
                            .add(LoginButtonPressed());
                      },
                      child:
                          Text(creatingNewAccount ? 'Create Account' : 'Login'),
                    ),
                    RaisedButton(
                      child: Text(creatingNewAccount
                          ? 'Go to Login'
                          : 'Go to Create Account'),
                      onPressed: () {
                        _loginPageBloc.loginPageEventSink
                            .add(SwitchToCreateAccountButtonPressed());
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class LoginField extends StatelessWidget {
  bool obscureText;
  final String hint;
  final Function(String) onChanged;
  final Stream stream;

  LoginField({this.obscureText, this.hint, this.onChanged, this.stream}) {
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
              decoration:
                  InputDecoration(hintText: hint, errorText: snapshot.error),
            ),
          );
        });
  }
}
