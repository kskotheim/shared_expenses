import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/edit_delete_event_bloc.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/ui/group_page/categories/bill_categories.dart';
import 'package:shared_expenses/src/ui/group_page/edit_delete_event/edit_delete_event_dialog.dart';
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
              child: ListView(
                children: <Widget>[
                  BillCategoryList(),
                  Divider(),
                  UserModifierList(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: Style.floatingActionPadding,
                    child: FloatingActionButton(
                      heroTag: 'edit_delete_event',
                      child: Icon(Icons.edit),
                      backgroundColor: Colors.red,
                      onPressed: () => showDialog(
                        builder: (newContext) {
                          EditDeleteEventBloc editDeleteBloc = EditDeleteEventBloc(groupBloc: groupBloc);
                          return EditDeleteEventDialog(
                            editDeleteEventBloc: editDeleteBloc,
                            groupBloc: groupBloc,
                          );
                        },
                        context: context,
                      ),
                    ),
                  ),
                  Padding(
                    padding: Style.floatingActionPadding,
                    child: FloatingActionButton(
                      heroTag: 'exit_admin',
                      child: Icon(Icons.arrow_back),
                      backgroundColor: Colors.indigo,
                      onPressed: groupBloc.showGroupHomePage,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
