import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';



class SetUsernameWidget extends StatefulWidget {
  @override
  _SetUsernameWidgetState createState() => _SetUsernameWidgetState();
}

class _SetUsernameWidgetState extends State<SetUsernameWidget> {

  bool _editUsername;

  @override
  Widget build(BuildContext context) {
    AccountBloc accountBloc = BlocProvider.of<AccountBloc>(context);
    TextEditingController _nameController =
        TextEditingController(text: accountBloc.currentUser.userName);
    
    if(_editUsername == null) _editUsername = accountBloc.currentUser.userName == null;

    if(_editUsername)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Username:"),
          Container(
            width: 200.0,
            child: TextField(
              controller: _nameController,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FlatButton(
                child: Text('Submit'),
                onPressed: () {
                  accountBloc.accountEvent.add(AccountEventRenameUser(newName: _nameController.text));
                  setState((){
                    _editUsername = false;
                  });
                },
              ),
              FlatButton(child: Text('Cancel'),onPressed: (){
                setState(() {
                  _editUsername = false;
                });
              },),
            ],
          )
        ],
      );
    else return InkWell(
      onTap: (){
        setState(() {
          _editUsername = true;
        });
      },
      child: Column(
        children: <Widget>[
          Text('Username: ${accountBloc.currentUser.userName ?? 'No Username'}', style: TextStyle(fontSize: 18.0)),
          Text('Tap to edit', style: TextStyle(color: Colors.grey),)
        ],
      ),
    );
  }
}