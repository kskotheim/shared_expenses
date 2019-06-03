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
    else return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Username: ${accountBloc.currentUser.userName ?? 'No Username'}', style: TextStyle(fontSize: 18.0)),
          Container(width: 30.0),
          InkWell(
            onTap: (){
              setState(() {
                _editUsername = true;
              });
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(12.0, 5.0, 12.0, 5.0),
              child: Text('Edit'),
              decoration: BoxDecoration(border: Border.all(color: Colors.brown), borderRadius: BorderRadius.all(Radius.circular(5.0)), gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors:[Colors.orange, Colors.red])),
            ),
          )
        ],
    
    );
  }
}