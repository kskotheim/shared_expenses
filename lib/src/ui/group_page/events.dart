
import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/events_bloc.dart';

class EventsWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    EventsBloc eventsBloc = BlocProvider.of<EventsBloc>(context);
    return StreamBuilder<List<String>>(
        stream: eventsBloc.eventList,
        builder: (context, snapshot) {
          if (snapshot.data == null) return Text('no events data');
          return ListView(
            children: snapshot.data
                .map((t) => ListTile(
                      title: Text(t),
                    ))
                .toList(),
          );
        });
  }
}
