import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/requests_bloc.dart';

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
