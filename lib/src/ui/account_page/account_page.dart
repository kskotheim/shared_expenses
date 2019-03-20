import 'package:flutter/material.dart';
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
        ],
      ),
    );
  }
}
