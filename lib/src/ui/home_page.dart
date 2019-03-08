import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthBloc _authbloc = BlocProvider.of<AuthBloc>(context);

    return StreamBuilder<AuthState>(
        stream: _authbloc.authStream,
        builder: (context, snapshot) {
          if (snapshot.data == null) return Text('no data');
          return Text('hi ${snapshot.data.username}');
        });
  }
}
