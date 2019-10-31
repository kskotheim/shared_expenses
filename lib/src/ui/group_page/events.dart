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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SortButton(
                    text: 'all',
                    onPressed: eventsBloc.sortByAll,
                    onLongPress: eventsBloc.sortByAll,
                    selected: snapshot.data.sortList[0],
                  ),
                  SortButton(
                    text: 'bill',
                    onPressed: eventsBloc.addSortByBill,
                    onLongPress: eventsBloc.sortByBill,
                    selected: snapshot.data.sortList[1],
                  ),
                  SortButton(
                    text: 'payment',
                    onPressed: eventsBloc.addSortByPayment,
                    onLongPress: eventsBloc.sortByPayment,
                    selected: snapshot.data.sortList[2],
                  ),
                  SortButton(
                    text: 'event',
                    onPressed: eventsBloc.addSortByEvent,
                    onLongPress: eventsBloc.sortByAccountEvents,
                    selected: snapshot.data.sortList[3],
                  ),
                ],
              );
            }),
        StreamBuilder<List<List<Widget>>>(
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
                              leading: textWidget[2],
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
  final onLongPress;
  final bool selected;

  SortButton({this.text, this.selected, this.onPressed, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          color: selected ? Colors.grey.shade200 : null,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          style: Style.tinyTextStyle,
        ),
      ),
    );
  }
}

class EventListTile extends StatefulWidget {
  final Text title;
  final Text subtitle;
  final Widget leading;
  final Key key = UniqueKey();

  EventListTile({this.title, this.subtitle, this.leading});

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
      leading: widget.leading,
      title: widget.title,
      subtitle: expanded ? widget.subtitle : null,
    );
  }
}
