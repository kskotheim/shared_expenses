import 'package:flutter/material.dart';

import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  AuthBloc _authBloc;
  final LoginField _nameField = LoginField(hint: 'username');
  final LoginField _passwordField = LoginField(obscureText: obscurePasswordText, hint: 'password');
  final LoginField _secondPasswordField = LoginField(obscureText: obscurePasswordText, hint: 'verify password');

  //local state variables managed in this class
  static bool obscurePasswordText = true;
  static bool creatingNewAccount = false;

  @override
  Widget build(BuildContext context) {
    _authBloc = BlocProvider.of<AuthBloc>(context);
    return Padding(
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
              if(creatingNewAccount) _authBloc.createAcct(_nameField.text, _passwordField.text);
              else _authBloc.login(_nameField.text, _passwordField.text);
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
    );
  }
}

class LoginField extends StatelessWidget {
  bool obscureText;
  String hint;
  String error;

  LoginField({this.obscureText, this.hint, this.error}) {
    if (obscureText == null) obscureText = false;
  }

  final TextEditingController _controller = TextEditingController();
  String get text => _controller.text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.0,
      child: TextFormField(
        controller: _controller,
        obscureText: obscureText,
        decoration: InputDecoration(hintText: hint, errorText: error),
      ),
    );
  }
}
