import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/events_bloc.dart';
import 'package:shared_expenses/src/ui/home_page/connection_requests.dart';
import 'package:shared_expenses/src/ui/home_page/events.dart';
import 'package:shared_expenses/src/ui/home_page/new_event/new_event.dart';
import 'package:shared_expenses/src/ui/home_page/totals.dart';

class HomePage extends StatelessWidget {
  EventsBloc _eventsBloc;

  @override
  Widget build(BuildContext context) {
    AccountBloc accountBloc = BlocProvider.of<AccountBloc>(context);
    _eventsBloc = EventsBloc(accountBloc: accountBloc);

    final Widget goToSelectAccountButton = Padding(
        padding: const EdgeInsets.fromLTRB(9.0, 18.0, 9.0, 18.0),
        child: FloatingActionButton(
          
          backgroundColor: Colors.grey,
          child: Icon(Icons.account_circle),
          onPressed: () =>
              accountBloc.accountEvent.add(AccountEventGoToSelect()),
        ));

    final Widget accountAdminButton = accountBloc.permissions.contains('owner')
    ? Padding(
      padding: const EdgeInsets.fromLTRB(9.0, 18.0, 9.0, 18.0),
      child: FloatingActionButton(
      child: Icon(Icons.supervisor_account),
      onPressed: () => showDialog(context: context, builder: (newContext) => Dialog(child: ConnectionRequestsList(accountBloc: accountBloc,),)),
    ))
    : Container();

    return BlocProvider(
      bloc: _eventsBloc,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: 10.0,
              ),
              Text(accountBloc.currentAccount.accountName,
                  style: TextStyle(fontSize: 25.0)),
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
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                goToSelectAccountButton,
                accountAdminButton,
                NewEventButton(
                  eventsBloc: _eventsBloc,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  
}
