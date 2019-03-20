import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';

class ConnectAccountSection extends StatefulWidget {
  @override
  _ConnectAccountSectionState createState() => _ConnectAccountSectionState();
}

class _ConnectAccountSectionState extends State<ConnectAccountSection> {
  bool _connectAccount = false;
  AccountBloc _accountBloc;

  @override
  Widget build(BuildContext context) {
    _accountBloc = BlocProvider.of<AccountBloc>(context);
    return !_connectAccount ? _createAccountButton() : _createAccountField();
  }

  Widget _createAccountButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _connectAccount = true;
        });
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, style: BorderStyle.solid),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Column(
          children: <Widget>[
            Icon(Icons.transit_enterexit),
            Text('Connect To Account'),
          ],
        ),
      ),
    );
  }

  Widget _createAccountField() {

    TextEditingController _nameController =TextEditingController();


    return StreamBuilder<Object>(
      stream: _accountBloc.accountNameErrors,
      builder: (context, snapshot) {
        return Column(
          children: <Widget>[
            Text("Request Connection To:"),
              Container(
                width: 200.0,
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    errorText: snapshot.error,
                  ),
                ),
              ),


            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  child: Text('Submit'),
                  //Send connect to account event to account bloc
                  onPressed: () => _accountBloc.accountEvent.add(AccountEventSendConnectionRequest(accountName: _nameController.text)),
                ),
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    setState(() {
                      _connectAccount = false;
                    });
                  },
                ),
              ],
            )
          ],
        );
      }
    );
  }
}
