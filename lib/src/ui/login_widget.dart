import 'package:flutter/material.dart';

import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/login_page_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/res/util.dart';

class LoginWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    LoginPageBloc loginPageBloc = LoginPageBloc(authBloc: authBloc);

    LoginField _nameField = LoginField(
      hint: 'email',
      onChanged: loginPageBloc.changeName,
      stream: loginPageBloc.email,
    );
    LoginField _passwordField = LoginField(
      obscureText: true,
      hint: 'password',
      onChanged: loginPageBloc.changePassword,
      stream: loginPageBloc.password,
    );
    LoginField _secondPasswordField = LoginField(
      obscureText: true,
      hint: 'verify password',
      onChanged: loginPageBloc.changeverifiedPassword,
      stream: loginPageBloc.verifiedPassword,
    );

    return BlocProvider(
      bloc: loginPageBloc,
      child: StreamBuilder<Object>(
          stream: loginPageBloc.loginPageState,
          builder: (context, snapshot) {
            if (snapshot.data == null) return Text('no data in login field');

            bool creatingNewAccount = snapshot.data is ShowCreateAccountPage;
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Shared Expenses',
                      style: Style.titleTextStyle,
                    ),
                    Container(
                      height: 10.0,
                    ),
                    IconImage30Pct(),
                    Container(
                      height: 10.0,
                    ),
                    Text(
                      creatingNewAccount ? 'Create New Account:' : 'Login:',
                      style: Style.tinyTextStyle,
                    ),
                    _nameField,
                    _passwordField,
                    creatingNewAccount ? _secondPasswordField : Container(),
                    Container(height: 40),
                    RaisedButton(
                      onPressed: () {
                        loginPageBloc.loginPageEventSink
                            .add(LoginButtonPressed());
                      },
                      child: Text(
                          creatingNewAccount ? 'Create Account' : 'Login',
                          style: Style.regularTextStyle),
                    ),
                    RaisedButton(
                      child: Text(
                        creatingNewAccount
                            ? 'Go to Login'
                            : 'Go to Create Account',
                        style: Style.regularTextStyle,
                      ),
                      onPressed: () {
                        loginPageBloc.loginPageEventSink
                            .add(SwitchToCreateAccountButtonPressed());
                      },
                    ),
                    Container(
                      height: 40.0,
                    ),
                    ResetPasswordButton()
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
              style: Style.regularTextStyle,
              decoration:
                  InputDecoration(hintText: hint, errorText: snapshot.error),
            ),
          );
        });
  }
}

class ResetPasswordButton extends StatefulWidget {
  @override
  _ResetPasswordButtonState createState() => _ResetPasswordButtonState();
}

class _ResetPasswordButtonState extends State<ResetPasswordButton> {
  bool sending = false;

  @override
  Widget build(BuildContext context) {
    LoginPageBloc loginPageBloc = BlocProvider.of<LoginPageBloc>(context);

    if (sending) {
      return FlatButton(
        onPressed: null,
        child: Text('Sending ...'),
      );
    }
    return FlatButton(
      child: Text('Reset Password'),
      onPressed: () async {
        setState(() => sending = true);
        await loginPageBloc.resetPassword();
        setState(() => sending = false);
      },
    );
  }
}
