import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/edit_delete_dialog_bloc.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/new_ghost_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/ui/group_page/admin/ghost_user_dialog.dart';
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
                      onPressed: () {
                        EditDeleteDialogBloc editDeleteBloc =
                            EditDeleteDialogBloc(groupBloc: groupBloc);
                        return showDialog(
                          builder: (newContext) {
                            return EditDeleteEventDialog(
                              editDeleteEventBloc: editDeleteBloc,
                              groupBloc: groupBloc,
                            );
                          },
                          context: context,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: Style.floatingActionPadding,
                    child: FloatingActionButton(
                      heroTag: 'ghost_users',
                      child: Icon(Icons.supervised_user_circle),
                      backgroundColor: Colors.blueGrey.shade300,
                      onPressed: () {
                        NewGhostBloc newGhostBloc =
                            NewGhostBloc(groupBloc: groupBloc);
                        return showDialog(
                            context: context,
                            builder: (newContext) {
                              return GhostUserDialog(
                                  groupBloc: groupBloc,
                                  ghostBloc: newGhostBloc);
                            });
                      },
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
