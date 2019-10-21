import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/new_event_bloc.dart';
import 'package:shared_expenses/src/ui/group_page/new_event/new_event_dialog.dart';

class NewEventButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(9.0, 18.0, 9.0, 18.0),
      child: FloatingActionButton(
        onPressed: () {
          NewEventBloc.resetVals();
          showDialog(
            context: context,
            builder: (newContext) => NewEventDialog(
              groupBloc: BlocProvider.of<GroupBloc>(context),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
