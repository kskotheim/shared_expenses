import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/events_bloc.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/requests_bloc.dart';
import 'package:shared_expenses/src/ui/group_page/account_management.dart';
import 'package:shared_expenses/src/ui/group_page/connection_requests.dart';
import 'package:shared_expenses/src/ui/group_page/events.dart';
import 'package:shared_expenses/src/ui/group_page/new_event/new_event.dart';
import 'package:shared_expenses/src/ui/group_page/totals.dart';

class GroupPage extends StatelessWidget {
  final String groupId;
  EventsBloc _eventsBloc;

  GroupPage({this.groupId}) : assert(groupId != null);

  @override
  Widget build(BuildContext context) {
    AccountBloc accountBloc = BlocProvider.of<AccountBloc>(context);
    GroupBloc groupBloc = GroupBloc(
        accountBloc: accountBloc,
        userId: accountBloc.currentUser.userId,
        accountId: groupId);

    _eventsBloc = EventsBloc(groupBloc: groupBloc);

    final Widget goToSelectAccountButton = Padding(
        padding: const EdgeInsets.fromLTRB(9.0, 18.0, 9.0, 18.0),
        child: FloatingActionButton(
          heroTag: 'account',
          backgroundColor: Colors.grey,
          child: Icon(Icons.account_circle),
          onPressed: () =>
              accountBloc.accountEvent.add(AccountEventGoToSelect()),
        ));

    return BlocProvider(
      bloc: groupBloc,
      child: BlocProvider(
        bloc: _eventsBloc,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(groupBloc.currentAccount.accountName,
                        style: TextStyle(fontSize: 25.0)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: TotalsWidget(),
                    color: Colors.grey.shade200,
                  ),
                ),
                Expanded(
                  flex: 4,
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  goToSelectAccountButton,
                  BillCategoryButton(),
                  ConnectionRequestsButton(),
                  NewEventButton(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ConnectionRequestsButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    GroupBloc groupBloc = BlocProvider.of<GroupBloc>(context);
    if (groupBloc.permissions.contains('owner')) {
      RequestsBloc requestsBloc = RequestsBloc(accountId: groupBloc.accountId);

      return StreamBuilder(
        stream: requestsBloc.requests,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          int numRequests = snapshot.data.length;

          if (numRequests > 0) {
            return Padding(
                padding: const EdgeInsets.fromLTRB(9.0, 18.0, 9.0, 18.0),
                child: Stack(
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: 'connection_requests',
                      child: Icon(Icons.supervisor_account),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (newContext) => Dialog(
                                child: ConnectionRequestsList(
                                  requestsBloc: requestsBloc,
                                ),
                              )),
                    ),
                    Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: Colors.yellow),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          '$numRequests',
                        ),
                      ),
                    )
                  ],
                ));
          } else
            return Container();
        },
      );
    } else {
      return Container();
    }
  }
}

class BillCategoryButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    GroupBloc groupBloc = BlocProvider.of<GroupBloc>(context);
    if (groupBloc.permissions.contains('owner')) {
      return Padding(
          padding: const EdgeInsets.fromLTRB(9.0, 18.0, 9.0, 18.0),
          child: FloatingActionButton(
            heroTag: 'account_management',
            backgroundColor: Colors.orange,
            child: Icon(Icons.apps),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AccountManager())),
            
            // showDialog(
            //     context: context,
            //     builder: (newContext) => Dialog(
            //           child: BillCategoryList(
            //             groupBloc: groupBloc,
            //           ),
            //         )),
          ));
    } else
      return Container();
  }
}
