import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/ui/login_widget.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final AuthBloc _authBloc = AuthBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BlocProvider(
        bloc: _authBloc,
        child: Center(
          child: StreamBuilder(
            stream:_authBloc.authStream,
            builder: (BuildContext context, AsyncSnapshot<AuthState> snapshot){
              if(!snapshot.hasData) return Container(child: Text('no data'));
              if(snapshot.data is AuthStateLoggedIn){
                return Text('hi ${snapshot.data.username}');
              }
              if(snapshot.data is AuthStateNotLoggedIn){
                return LoginWidget();
              }
              if(snapshot.data is AuthStateLoading){
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
