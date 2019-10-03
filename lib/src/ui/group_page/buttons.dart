import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/requests_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';


class GoToSelectAccountButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AccountBloc accountBloc = BlocProvider.of<AccountBloc>(context);

    return Padding(
        padding: Style.floatingActionPadding,
        child: FloatingActionButton(
          heroTag: 'account',
          backgroundColor: Colors.grey,
          child: Icon(Icons.account_circle),
          onPressed: () =>
              accountBloc.accountEvent.add(AccountEventGoToSelect()),
        ));
  }
}

class ConnectionRequestsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GroupBloc groupBloc = BlocProvider.of<GroupBloc>(context);
    if (groupBloc.isGroupOwner) {
      RequestsBloc requestsBloc = RequestsBloc(accountId: groupBloc.accountId);

      return StreamBuilder(
        stream: requestsBloc.requests,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          int numRequests = snapshot.data.length;

          if (numRequests > 0) {
            return Padding(
                padding: Style.floatingActionPadding,
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
    if (groupBloc.isGroupOwner) {
      return Padding(
          padding: Style.floatingActionPadding,
          child: FloatingActionButton(
            heroTag: 'account_management',
            backgroundColor: Colors.orange,
            child: Icon(Icons.apps),
            onPressed: groupBloc.showGroupAdminPage,

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




class ConnectionRequestsList extends StatelessWidget {

  String acctId;
  RequestsBloc requestsBloc;

  ConnectionRequestsList({this.acctId, this.requestsBloc}) : assert(acctId != null || requestsBloc != null);

  @override
  Widget build(BuildContext context) {
    if(requestsBloc == null) requestsBloc = RequestsBloc(accountId: acctId);

    return BlocProvider(
      bloc: requestsBloc,
          child: StreamBuilder<List<List<String>>>(
          stream: requestsBloc.requests,
          builder: (context, snapshot) {
            if (snapshot.data == null) return Text('no connection requests');
            return ListView(
              shrinkWrap: true,
              children: snapshot.data.map((request) => ListTile(
                title: Text(request[0]),
                leading: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: (){
                    requestsBloc.approveConnectionRequest(request[1]);
                  },
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: (){
                    requestsBloc.deleteConnectionRequest(request[1]);
                  },
                ),
              )).toList(),
            );
          }),
    );
  }
}
