import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/events_bloc.dart';
import 'package:shared_expenses/src/ui/home_page/connection_requests.dart';
import 'package:shared_expenses/src/ui/home_page/events.dart';
import 'package:shared_expenses/src/ui/home_page/new_event.dart';
import 'package:shared_expenses/src/ui/home_page/totals.dart';

class HomePage extends StatelessWidget {
  EventsBloc _eventsBloc;

  @override
  Widget build(BuildContext context) {
    AccountBloc accountBloc = BlocProvider.of<AccountBloc>(context);
    _eventsBloc = EventsBloc(accountId: accountBloc.currentAccount.accountId);

    var goToSelectAccountButton = IconButton(
      icon: Icon(Icons.account_circle),
      onPressed: () => accountBloc.accountEvent.add(AccountEventGoToSelect()),
    );

    return BlocProvider(
      bloc: _eventsBloc,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: TotalsWidget(),
              ),
              Divider(),
              Expanded(
                flex: 2,
                child: EventsWidget(
                  eventsBloc: _eventsBloc,
                ),
              ),
              Divider(),
              Expanded(
                child: ConnectionRequestsList(),
                flex: 1,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              goToSelectAccountButton,
              NewEventButton(
                eventsBloc: _eventsBloc,
              ),
            ],
          )
        ],
      ),
    );
  }
}
