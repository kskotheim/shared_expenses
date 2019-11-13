import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/res/style.dart';



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
          Text("Name:", style: Style.regularTextStyle,),
          Container(
            width: 200.0,
            child: TextField(
              controller: _nameController,
              style: Style.subTitleTextStyle,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FlatButton(
                child: Text('Submit', style: Style.regularTextStyle,),
                onPressed: () {
                  accountBloc.accountEvent.add(AccountEventRenameUser(newName: _nameController.text));
                  setState((){
                    _editUsername = false;
                  });
                },
              ),
              FlatButton(child: Text('Cancel', style: Style.regularTextStyle,),onPressed: (){
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
          Text('Name: ${accountBloc.currentUser.userName ?? 'No Username'}', style: Style.regularTextStyle),
          Container(width: 30.0),
          InkWell(
            onTap: (){
              setState(() {
                _editUsername = true;
              });
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(12.0, 5.0, 12.0, 5.0),
              child: Text('Edit', style: Style.tinyTextStyle,),
              decoration: Style.editDeleteDecorationReverse,
            ),
          )
        ],
    
    );
  }
}