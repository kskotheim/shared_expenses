import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/ui/account_page/account_page.dart';
import 'package:shared_expenses/src/ui/home_page.dart';

class AccountRoot extends StatelessWidget {
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


