import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/res/style.dart';

class SelectAccountWidget extends StatelessWidget {
  AccountBloc _accountBloc;

  @override
  Widget build(BuildContext context) {
    _accountBloc = BlocProvider.of<AccountBloc>(context);

    if( _accountBloc.accountNames == null) return Text('no user data');
    List<AccountListTile> selectAccountTile = _accountBloc.currentUserGroups.map((accountId) => AccountListTile(accountId: accountId,)).toList();
    
    return Column(
      children: <Widget>[
           Text( selectAccountTile.isEmpty ? 'No Accounts' : 'Select Account:', style: Style.subTitleTextStyle,)
          ] +
          selectAccountTile,
    );
  }
}

class AccountListTile extends StatelessWidget {
  final String accountId;
  AccountListTile({this.accountId});
  AccountBloc _accountBloc;

  @override
  Widget build(BuildContext context) {
    _accountBloc = BlocProvider.of<AccountBloc>(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: InkWell(
        
        child: Container(
          padding: EdgeInsets.fromLTRB(32.0, 15.0, 32.0, 15.0),
          decoration: BoxDecoration(border: Border.all(color: Colors.brown), borderRadius: BorderRadius.all(Radius.circular(12.0)), gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Colors.greenAccent, Colors.lightBlueAccent])),
          child: Text(_accountBloc.accountNames[accountId] ?? 'error finding account', style: Style.boldSubTitleStyle,),
        ),
        onTap: () => _accountBloc.accountEvent
            .add(AccountEventGoHome(accountId: accountId)),
      ),
    );
  }
}