import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/res/models/account.dart';
import 'package:shared_expenses/src/res/style.dart';

class SelectAccountWidget extends StatelessWidget {
  AccountBloc _accountBloc;

  @override
  Widget build(BuildContext context) {
    _accountBloc = BlocProvider.of<AccountBloc>(context);

    if (_accountBloc.groups == null) return Text('no group data');
    List<AccountListTile> selectAccountTile = _accountBloc.groups
        .map((group) => AccountListTile(
              group: group,
            ))
        .toList();

    return Column(
      children: <Widget>[
            Text(
              selectAccountTile.isEmpty ? 'No Groups' : 'Select Group:',
              style: Style.subTitleTextStyle,
            )
          ] +
          selectAccountTile,
    );
  }
}

class AccountListTile extends StatefulWidget {
  final Account group;
  AccountListTile({this.group});

  @override
  _AccountListTileState createState() => _AccountListTileState();
}

class _AccountListTileState extends State<AccountListTile> {
  bool showDeleteOption = false;

  @override
  Widget build(BuildContext context) {
    AccountBloc accountBloc = BlocProvider.of<AccountBloc>(context);

    Widget button = Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: InkWell(
        child: Container(
          padding: EdgeInsets.fromLTRB(32.0, 15.0, 32.0, 15.0),
          decoration: Style.selectAccountDecoration(widget.group.owner == accountBloc.currentUser.userId),
          child: Text(
            widget.group.accountName,
            style: Style.boldSubTitleStyle,
          ),
        ),
        onTap: () => accountBloc.accountEvent
            .add(AccountEventGoHome(accountId: widget.group.accountId)),
        onLongPress: widget.group.owner == accountBloc.currentUser.userId
            ? () => setState(() => showDeleteOption = !showDeleteOption)
            : null,
      ),
    );
    if (!showDeleteOption) {
      return button;
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          button,
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Warning'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                            'This action can not be undone. All users will permanently lose access to this group and any data it contains.'),
                        FlatButton(
                          child: Text('Yes, Delete'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                      ],
                    ),
                  );
                },
              ).then(
                (result) {
                  if (result) {
                    accountBloc.deleteGroup(widget.group.accountId);
                  }
                },
              );
            },
          )
        ],
      );
    }
  }
}
