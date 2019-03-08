import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/ui/home_page.dart';
import 'package:shared_expenses/src/ui/login_widget.dart';

class RootWidget extends StatelessWidget {
  RootWidget({Key key, this.title}) : super(key: key);

  final String title;
  final AuthBloc _authBloc = AuthBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _authBloc,
      child: StreamBuilder(
          stream: _authBloc.authStream,
          builder: (BuildContext context, AsyncSnapshot<AuthState> snapshot) {
            if (!snapshot.hasData) return Container(child: Text('no data'));
            Widget pageToRender;
            if (snapshot.data is AuthStateLoggedIn) {
              pageToRender = HomePage();
            }
            if (snapshot.data is AuthStateNotLoggedIn) {
              pageToRender = LoginWidget();
            }
            if (snapshot.data is AuthStateLoading) {
              pageToRender = CircularProgressIndicator();
            }

            return Scaffold(
                appBar: AppBar(
                  title: Text(title),
                  actions: <Widget>[
                    !(snapshot.data is AuthStateNotLoggedIn)
                    ? FlatButton(
                      child: Text('logout'),
                      onPressed: _authBloc.logout,
                      textColor: Colors.white,
                    )
                    : Container(),
                  ],
                ),
                body: Center(child: pageToRender));
          }),
    );
  }
}
