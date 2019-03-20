import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/requests_bloc.dart';

class ConnectionRequestsList extends StatelessWidget {

  AccountBloc _accountBloc;
  RequestsBloc _requestsBloc;

  @override
  Widget build(BuildContext context) {
    _accountBloc = BlocProvider.of<AccountBloc>(context);
    _requestsBloc = RequestsBloc(accountBloc: _accountBloc);

    return BlocProvider(
      bloc: _requestsBloc,
          child: StreamBuilder<List<String>>(
          stream: _requestsBloc.requests,
          builder: (context, snapshot) {
            if (snapshot.data == null) return Text('no connection requests');
            return ListView(
              children: snapshot.data.map((name) => ListTile(title: Text(name))).toList(),
            );
          }),
    );
  }
}
