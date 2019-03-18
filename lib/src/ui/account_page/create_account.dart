import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';

class CreateAccountSection extends StatefulWidget {
  @override
  _CreateAccountSectionState createState() => _CreateAccountSectionState();
}

class _CreateAccountSectionState extends State<CreateAccountSection> {
  bool _createAccount = false;
  AccountBloc _accountBloc;

  @override
  Widget build(BuildContext context) {
    _accountBloc = BlocProvider.of<AccountBloc>(context);
    return !_createAccount ? _createAccountButton() : _createAccountField();
  }

  Widget _createAccountButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _createAccount = true;
        });
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey, style: BorderStyle.solid),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Column(
          children: <Widget>[
            Icon(Icons.add),
            Text('Create Account'),
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
            Text("Account Name:"),
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
                  onPressed: () => _accountBloc.accountEvent.add(AccountEventCreateAccount(accountName: _nameController.text)),
                ),
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    setState(() {
                      _createAccount = false;
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
