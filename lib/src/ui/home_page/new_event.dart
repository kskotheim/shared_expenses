import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/events_bloc.dart';

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
          onPressed: () => eventsBloc.addEvent('hi'),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}