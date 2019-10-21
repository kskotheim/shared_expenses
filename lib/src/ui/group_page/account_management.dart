import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/ui/group_page/categories/bill_categories.dart';
import 'package:shared_expenses/src/ui/group_page/user_modifiers/user_modifiers.dart';

class AccountManager extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    GroupBloc groupBloc = BlocProvider.of<GroupBloc>(context);

    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  BillCategoryList(),
                  Divider(),
                  UserModifierList(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: Style.floatingActionPadding,
                child: FloatingActionButton(
                  heroTag: 'exit_admin',
                  child: Icon(Icons.arrow_back),
                  backgroundColor: Colors.indigo,
                  onPressed: groupBloc.showGroupHomePage,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
