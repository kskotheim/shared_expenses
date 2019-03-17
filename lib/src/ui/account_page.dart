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
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 50.0,
          ),
          SetUsernameWidget(),
          Container(
            height: 60.0,
          ),
          SelectAccountWidget(),
          Container(
            height: 40.0,
          ),
          CreateAccountSection()
        ],
      ),
    );
  }
}

class SetUsernameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AccountBloc accountBloc = BlocProvider.of<AccountBloc>(context);
    TextEditingController _theController =
        TextEditingController(text: accountBloc.currentUser.userName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Username:"),
        Container(
          width: 200.0,
          child: TextField(
            controller: _theController,
          ),
        ),
        FlatButton(
          child: Text('Submit'),
          onPressed: () => accountBloc.accountEvent
              .add(AccountEventRenameUser(newName: _theController.text)),
        )
      ],
    );
  }
}

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

class CreateAccountSection extends StatefulWidget {
  @override
  _CreateAccountSectionState createState() => _CreateAccountSectionState();
}

class _CreateAccountSectionState extends State<CreateAccountSection> {
  bool _createAccount = false;

  @override
  Widget build(BuildContext context) {
    return !_createAccount ? _createAccountButton() : _createAccountField();
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

  Widget _createAccountField() {
    return Column(
      children: <Widget>[
        Text("Ok here we go"),
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            setState(() {
              _createAccount = false;
            });
          },
        )
      ],
    );
  }
}
