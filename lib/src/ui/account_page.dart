import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/ui/home_page.dart';

class AccountPage extends StatelessWidget {
  AccountBloc _accountBloc;
  AuthBloc _authBloc;

  @override
  Widget build(BuildContext context) {
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _accountBloc = AccountBloc(authBloc: _authBloc);

    return BlocProvider(
      bloc: _accountBloc,
      child: StreamBuilder<AccountState>(
          stream: _accountBloc.accountState,
          builder: (context, snapshot) {
            if (snapshot.data == null) return Container();

            AccountState state = snapshot.data;

            if (state is AccountStateLoading) {
              return LinearProgressIndicator();
            }

            if (state is AccountStateHome) {
              return HomePage();
            }

            if (state is AccountStateSelect) {
              return SelectAccountPage();
            }
          }),
    );
  }
}

class SelectAccountPage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new SelectAccountWidget(),
        Container(height: 40.0,),
        CreateAccountSection()
      ],
    );
  }
}

class SelectAccountWidget extends StatelessWidget {
  AccountBloc _accountBloc;

  @override
  Widget build(BuildContext context) {
    _accountBloc = BlocProvider.of<AccountBloc>(context);
    List<Widget> theTileList = _accountBloc.currentUser.accounts.map((account) => ListTile(title: Text( _accountBloc.accountNames[account] ))).toList();
    return Column(children: <Widget>[
      theTileList.isEmpty 
      ? Text('No Accounts')
      : Text('Select Account:')
    ] + theTileList,);
  }
}


class CreateAccountSection extends StatefulWidget {
  @override
  _CreateAccountSectionState createState() => _CreateAccountSectionState();
}

class _CreateAccountSectionState extends State<CreateAccountSection> {
  bool _createAccount = false;

  @override
  Widget build(BuildContext context) {
    return !_createAccount 
            ? _createAccountButton()
            : _createAccountField();
  }

  Widget _createAccountButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _createAccount = true;          
        });
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey, style: BorderStyle.solid),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Column(
          children: <Widget>[
            Icon(Icons.add),
            Text('Create Account'),
          ],
        ),
      ),
    );
  }

  Widget _createAccountField(){
    return Column(
      children: <Widget>[
        Text("Ok here we go"),

         FlatButton(child: Text('Cancel'), onPressed: (){
           setState(() {
             _createAccount = false;
           });
         },)
      ],
    );
  }

}
