import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/ui/account_root.dart';
import 'package:shared_expenses/src/ui/login_widget.dart';

class RootWidget extends StatelessWidget {
  RootWidget({Key key}) : super(key: key);

  final AuthBloc _authBloc = AuthBloc();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
              pageToRender = AccountRoot(scaffoldKey: _scaffoldKey,);
            }
            if (snapshot.data is AuthStateNotLoggedIn) {
              AuthStateNotLoggedIn state = snapshot.data;
              if(state.error != null)
                WidgetsBinding.instance.addPostFrameCallback((_) => _showErrorMessage(state.error));
              pageToRender = LoginWidget();
            }
            if (snapshot.data is AuthStateLoading) {
              pageToRender = CircularProgressIndicator();
            }

            return Scaffold(
                key: _scaffoldKey,
                body: Center(child: pageToRender));
          }),
    );
  }

  void _showErrorMessage(String error) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(error),));
  }
}
