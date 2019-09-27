import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/events_bloc.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/ui/group_page/account_management.dart';
import 'package:shared_expenses/src/ui/group_page/events.dart';
import 'package:shared_expenses/src/ui/group_page/new_event/new_event.dart';
import 'package:shared_expenses/src/ui/group_page/totals.dart';

import 'buttons.dart';

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

    return BlocProvider(
      bloc: groupBloc,
      child: BlocProvider(
        bloc: _eventsBloc,
        child: StreamBuilder<GroupPageToShow>(
            stream: groupBloc.groupPageToShowStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();

              if (snapshot.data is ShowGroupHomePage) {
                return GroupHomePage();
              }
              if (snapshot.data is ShowGroupAdminPage) {
                return AccountManager();
              }
            }),
      ),
    );
  }
}

class GroupHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    GroupBloc groupBloc = BlocProvider.of<GroupBloc>(context);
    AccountBloc accountBloc = BlocProvider.of<AccountBloc>(context);

    return Stack(
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
              child: EventsWidget(),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              GoToSelectAccountButton(),
              BillCategoryButton(),
              ConnectionRequestsButton(),
              NewEventButton(),
            ],
          ),
        )
      ],
    );
  }
}
