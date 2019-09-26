
import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/totals_bloc.dart';

class TotalsWidget extends StatelessWidget {
  TotalsBloc _totalsBloc;

  @override
  Widget build(BuildContext context) {
    GroupBloc groupBloc = BlocProvider.of<GroupBloc>(context);
     _totalsBloc = TotalsBloc(groupBloc: groupBloc);
    return BlocProvider(
      bloc: _totalsBloc,
      child: StreamBuilder<List<ListTile>>(
          stream: _totalsBloc.totalsList,
          builder: (context, snapshot) {
            if (snapshot.data == null) return Text('no totals data');
            return ListView(
              children: snapshot.data,
            );
          }),
    );
  }
}