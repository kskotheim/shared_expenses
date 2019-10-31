import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/res/style.dart';

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
            Text('Connect To Account', style: Style.regularTextStyle),
          ],
        ),
      ),
    );
  }

  Widget _createAccountField() {
    TextEditingController _nameController = TextEditingController();

    return Column(
      children: <Widget>[
        Text("Request Connection To:", style: Style.regularTextStyle),
        Container(
          width: 200.0,
          child: TextField(
            style: Style.regularTextStyle,
            controller: _nameController,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FlatButton(
              child: Text('Submit', style: Style.regularTextStyle,),
              //Send connect to account event to account bloc
              onPressed: () => _accountBloc.accountEvent.add(
                  AccountEventSendConnectionRequest(
                      accountName: _nameController.text)),
            ),
            FlatButton(
              child: Text('Cancel', style: Style.regularTextStyle),
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
}
