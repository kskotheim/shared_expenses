import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/new_user_modifier_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/ui/group_page/user_modifiers/new_modifier_dialog.dart';

class NewModifierButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GroupBloc groupBloc = BlocProvider.of<GroupBloc>(context);
    return Container(
      padding: Style.floatingActionPadding,
      child: IconButton(
        icon: Icon(Icons.add),
        onPressed: () {
          NewUserModifierBloc newUserModifierBloc = NewUserModifierBloc(groupBloc: groupBloc);
          showDialog(
              context: context,
              builder: (newContext) => NewModifierDialog(
                    groupBloc: groupBloc,
                    userModifierBloc: newUserModifierBloc,
                  ));
        },
      ),
    );
  }
}
