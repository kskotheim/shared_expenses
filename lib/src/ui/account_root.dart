import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/auth_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/ui/account_page/account_page.dart';
import 'package:shared_expenses/src/ui/group_page/group_page.dart';

class AccountRoot extends StatelessWidget {
  AccountBloc _accountBloc;
  AuthBloc _authBloc;

  final GlobalKey<ScaffoldState> scaffoldKey;
  AccountRoot({this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _accountBloc = AccountBloc(authBloc: _authBloc);

    return BlocProvider(
      bloc: _accountBloc,
      child: StreamBuilder<PageToDisplay>(
          stream: _accountBloc.accountState,
          builder: (context, snapshot) {
            if (snapshot.data == null) return Container();

            PageToDisplay pageToDisplay = snapshot.data;

            if (pageToDisplay is DisplayLoadingPage) {
              return LinearProgressIndicator();
            }

            if (pageToDisplay is DisplayGroupPage) {
              return GroupPage(groupId: pageToDisplay.groupId);
            }

            if (pageToDisplay is DisplaySelectAccountPage) {
              DisplaySelectAccountPage thisState = pageToDisplay;
              if(thisState.error != null){
                WidgetsBinding.instance.addPostFrameCallback((_) => _showErrorMessage(thisState.error));
              }
              return SelectAccountPage();
            }
          }),
    );
  }

  void _showErrorMessage(String error) {
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(error),));
  }
}


