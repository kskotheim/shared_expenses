import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';

class SelectAccountWidget extends StatelessWidget {
  AccountBloc _accountBloc;

  @override
  Widget build(BuildContext context) {
    _accountBloc = BlocProvider.of<AccountBloc>(context);
    List<ListButtonTile> theTileList = _accountBloc.currentUser.accounts
        .map((account) =>
            ListButtonTile(title: Text(_accountBloc.accountNames[account])))
        .toList();
    for (int i = 0; i < theTileList.length; i++) {
      theTileList[i].index = i;
    }
    return Column(
      children: <Widget>[
            theTileList.isEmpty ? Text('No Accounts') : Text('Select Account:')
          ] +
          theTileList,
    );
  }
}

class ListButtonTile extends StatelessWidget {
  final Widget title;
  int index;
  ListButtonTile({this.title, this.index});
  AccountBloc _accountBloc;

  @override
  Widget build(BuildContext context) {
    _accountBloc = BlocProvider.of<AccountBloc>(context);

    return ListTile(
      title: title,
      onTap: () => _accountBloc.accountEvent
          .add(AccountEventGoHome(accountIndex: index)),
    );
  }
}