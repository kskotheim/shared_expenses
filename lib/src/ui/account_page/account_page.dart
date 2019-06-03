import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/user_requests_bloc.dart';
import 'package:shared_expenses/src/ui/account_page/connect_account.dart';
import 'package:shared_expenses/src/ui/account_page/create_account.dart';
import 'package:shared_expenses/src/ui/account_page/select_account.dart';
import 'package:shared_expenses/src/ui/account_page/set_username.dart';

class SelectAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 10.0,
          ),
          SetUsernameWidget(),
          Container(
            height: 10.0,
          ),
          EmailAddressWidget(),
          Container(
            height: 60.0,
          ),
          SelectAccountWidget(),
          Container(
            height: 40.0,
          ),
          CreateAccountSection(),
          Container(
            height: 10.0,
          ),
          ConnectAccountSection(),
          Container(
            height: 20.0,
          ),
          ConnectionRequestsSection(),
        ],
      ),
    );
  }
}

class EmailAddressWidget extends StatelessWidget {
  AccountBloc _accountBloc;
  AuthBloc _authBloc;

  @override
  Widget build(BuildContext context) {
    _accountBloc = BlocProvider.of<AccountBloc>(context);
    _authBloc = BlocProvider.of<AuthBloc>(context);

    String email = _accountBloc.currentUser.email;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Email: $email'),
        Container(width: 30.0),
        InkWell(
          child: Container(
            padding: EdgeInsets.fromLTRB(12.0, 5.0, 12.0, 5.0),
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0)), border: Border.all(color: Colors.brown), gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.redAccent, Colors.orangeAccent])),
            child: Text('Logout'),
          ),
          onTap: () => showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                    title: Text('Logout?'),
                    children: <Widget>[
                      FlatButton(
                        child: Text('Logout'),
                        onPressed: (){
                          _authBloc.logout();
                          return Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  )),
        )
      ],
    );
  }
}

class ConnectionRequestsSection extends StatelessWidget {
  AccountBloc _accountBloc;
  UserRequestsBloc _userRequestsBloc;

  @override
  Widget build(BuildContext context) {
    _accountBloc = BlocProvider.of<AccountBloc>(context);
    _userRequestsBloc =
        UserRequestsBloc(userId: _accountBloc.currentUser.userId);
    return BlocProvider(
      bloc: _userRequestsBloc,
      child: StreamBuilder<List<String>>(
        stream: _userRequestsBloc.requests,
        builder: (context, snapshot) {
          if (snapshot.data == null) return Container();
          return Column(
            children: <Widget>[
              snapshot.data.length != 0
                  ? Text('Connection Requests: ')
                  : Container(),
              Column(
                children:
                    snapshot.data.map((request) => Text(request)).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
