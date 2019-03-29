import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';

class EventDialog extends StatefulWidget {
 
  final AccountBloc accountBloc;

  EventDialog({this.accountBloc}) : assert(accountBloc != null);

  @override
  _EventDialogState createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  String _selectedVal = null;

  @override
  Widget build(BuildContext context) {
    Widget selectedSection = Container();
    if (_selectedVal == 'PAYMENT') {
      selectedSection = PaymentSection(
        accountBloc: widget.accountBloc,
      );
    } else if (_selectedVal == 'BILL') {
      selectedSection = BillSection();
    }

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(height: 10),
          Text('New Event', style: TextStyle(fontSize: 18.0)),
          Container(height: 30.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Event type:'),
              Container(
                width: 10.0,
              ),
              DropdownButton(
                items: _billOrPaymentMenuItems(),
                value: _selectedVal,
                onChanged: (val) {
                  setState(() {
                    _selectedVal = val;
                  });
                },
              )
            ],
          ),
          selectedSection,
          FlatButton(
            child: Text('Submit'),
            onPressed: () => Navigator.pop(context, _selectedVal),
          )
        ],
      ),
    );
  }

  List<DropdownMenuItem> _billOrPaymentMenuItems() {
    return [
      DropdownMenuItem(
        child: Text('Payment'),
        value: 'PAYMENT',
      ),
      DropdownMenuItem(
        value: 'BILL',
        child: Text('Bill'),
      ),
    ];
  }
}

class PaymentSection extends StatefulWidget {
  final AccountBloc accountBloc;

  PaymentSection({this.accountBloc}) : assert(accountBloc != null);

  @override
  _PaymentSectionState createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection> {
  String _userTo;
  List<DropdownMenuItem> _userMenuItems;

  @override
  Widget build(BuildContext context) {

    _userMenuItems = widget.accountBloc.usersInAccount
        .map((user) => DropdownMenuItem(
              child: Text(user.userName),
              value: user.userId,
            ))
        .toList();

    return Column(
      children: <Widget>[
        //to user
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('To: '),
            DropdownButton(
              items: _userMenuItems,
              value: _userTo,
              onChanged: (val) {
                setState(() {
                  print(val);
                  _userTo = val;
                });
              },
            ),
          ],
        ),

        //amount
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Amount: '),
            Container(
                width: 100.0,
                child: TextField(
                  keyboardType: TextInputType.number,
                )),
          ],
        ),


      ],
    );
  }
}

class BillSection extends StatefulWidget {
  @override
  _BillSectionState createState() => _BillSectionState();
}

class _BillSectionState extends State<BillSection> {
  String _billType = null;
  DateTime _fromDate;
  DateTime _toDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        //type
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Type: '),
            DropdownButton(
              value: _billType,
              items: _billTypes
                  .map((type) => DropdownMenuItem(
                        child: Text(type),
                        value: type,
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _billType = val;
                });
              },
            ),
          ],
        ),

        //amount
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Amount: '),
            Container(
                width: 100.0,
                child: TextField(
                  keyboardType: TextInputType.number,
                )),
          ],
        ),

        //datesApplied
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('From:'),
            FlatButton(
              child: Text(parseDateTime(_fromDate) ?? 'Current'),
              onPressed: () => pickDate(context).then((val){
                setState(() {
                  _fromDate = val;
                });
              }),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('To:'),
            FlatButton(
              child: Text(parseDateTime(_toDate) ?? 'Current'),
              onPressed: () => pickDate(context).then((val){
                setState(() {
                  _toDate = val;
                });
              }),
            ),
          ],
        )
      ],
    );
  }

  final List<String> _billTypes = ['Electric', 'Garbage', 'Internet', 'Other'];
}

Future<DateTime> pickDate(BuildContext context) {
  return showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.parse("20000101"),
    lastDate: DateTime.parse("21001231"),
  );
}

String parseDateTime(DateTime time){
  if(time == null) return null;
  return '${time.month}/${time.day}/${time.year % 2000}';
}