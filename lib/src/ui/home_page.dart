import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/events_bloc.dart';
import 'package:shared_expenses/src/bloc/totals_bloc.dart';
import 'package:shared_expenses/src/models/payment.dart';

class HomePage extends StatelessWidget {
  final EventsBloc _eventsBloc = EventsBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _eventsBloc,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: new TotalsWidget(),
              ),
              Divider(),
              Expanded(
                flex: 2,
                child: new EventsWidget(eventsBloc: _eventsBloc,),
              ),
            ],
          ),
          new NewEventButton(eventsBloc: _eventsBloc,)
        ],
      ),
    );
  }
}

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

class TotalsWidget extends StatelessWidget {
  final TotalsBloc _totalsBloc = TotalsBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _totalsBloc,
      child: StreamBuilder<List<Total>>(
          stream: _totalsBloc.totalsList,
          builder: (context, snapshot) {
            if (snapshot.data == null) return Text('no totals data');
            return ListView(
              children: snapshot.data
                .map((t) => ListTile(
                      title: Text(t.name),
                    ))
                .toList(),
            );
          }),
    );
  }
}

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
