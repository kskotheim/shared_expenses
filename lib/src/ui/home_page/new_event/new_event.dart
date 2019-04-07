import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/events_bloc.dart';
import 'package:shared_expenses/src/ui/home_page/new_event/new_event_dialog.dart';

class NewEventButton extends StatelessWidget {
  final EventsBloc eventsBloc;

  const NewEventButton({
    this.eventsBloc,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: FloatingActionButton(
          onPressed: () => showDialog(
            context: context,
            builder: (newContext) => NewEventDialog(
              accountBloc: BlocProvider.of<AccountBloc>(context),
            ),
          ),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}