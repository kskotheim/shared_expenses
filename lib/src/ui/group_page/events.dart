import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/events_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';

class EventsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    EventsBloc eventsBloc = BlocProvider.of<EventsBloc>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StreamBuilder<EventSortMethod>(
            stream: eventsBloc.eventSortMethod,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SortButton(
                    text: 'all',
                    onPressed: eventsBloc.sortByAll,
                    selected: snapshot.data is SortAll,
                  ),
                  SortButton(
                    text: 'bill',
                    onPressed: eventsBloc.sortByBill,
                    selected: snapshot.data is SortBills,
                  ),
                  SortButton(
                    text: 'payment',
                    onPressed: eventsBloc.sortByPayment,
                    selected: snapshot.data is SortPayments,
                  ),
                  SortButton(
                    text: 'event',
                    onPressed: eventsBloc.sortByAccountEvents,
                    selected: snapshot.data is SortAccountEvents,
                  ),
                ],
              );
            }),
        StreamBuilder<List<List<Text>>>(
            stream: eventsBloc.eventList,
            builder: (context, snapshot) {
              if (snapshot.data == null) return Text('no events data');
              return Expanded(
                child: Container(
                  padding: Style.eventsViewPadding,
                  child: ListView(
                    shrinkWrap: true,
                    children: snapshot.data
                        .map((textWidget) => EventListTile(
                              title: textWidget[0],
                              subtitle: textWidget[1],
                            ))
                        .toList(),
                  ),
                ),
              );
            }),
      ],
    );
  }
}

class SortButton extends StatelessWidget {
  final String text;
  final onPressed;
  final bool selected;

  SortButton({this.text, this.selected, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: selected ? Colors.grey.shade200 : Colors.white,
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(fontSize: 10.0, color: Colors.blueGrey),
      ),
    );
  }
}


class EventListTile extends StatefulWidget {

  final Text title;
  final Text subtitle;
  final Key key = UniqueKey();

  EventListTile({this.title, this.subtitle});

  @override
  _EventListTileState createState() => _EventListTileState();
}

class _EventListTileState extends State<EventListTile> {

  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: widget.key,
      onLongPress: () => setState(() => expanded = !expanded),
      title: widget.title,
      subtitle: expanded ? widget.subtitle : null,
    );
  }
}