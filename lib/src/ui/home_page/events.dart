
import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/events_bloc.dart';
import 'package:shared_expenses/src/res/models/payment.dart';

class EventsWidget extends StatelessWidget {
  final EventsBloc eventsBloc;

  const EventsWidget({this.eventsBloc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AnyEvent>>(
        stream: eventsBloc.eventList,
        builder: (context, snapshot) {
          if (snapshot.data == null) return Text('no events data');
          return ListView(
            children: snapshot.data
                .map((t) => ListTile(
                      title: Text(t.name),
                    ))
                .toList(),
          );
        });
  }
}
