import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/new_event_bloc.dart';

class BillSection extends StatelessWidget {
  NewEventBloc _newEventBloc;

  @override
  Widget build(BuildContext context) {
    _newEventBloc = BlocProvider.of<NewEventBloc>(context);

    return Column(
      children: <Widget>[
        //type
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Type: '),
            StreamBuilder<String>(
              stream: _newEventBloc.selectedType,
              builder: (context, snapshot) {
                return DropdownButton(
                  value: snapshot.data,
                  items: _newEventBloc.billTypeMenuItems,
                  onChanged: _newEventBloc.selectType,
                );
              }
            ),
          ],
        ),

        //amount
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Amount: '),
            StreamBuilder<double>(
              stream: _newEventBloc.billAmount,
              builder: (context, snapshot) {
                return Container(
                    width: 100.0,
                    child: TextField(
                      onChanged: _newEventBloc.newBillAmount,
                      keyboardType: TextInputType.number,
                    ));
              }
            ),
          ],
        ),

        //datesApplied
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('From:'),
            FlatButton(
              child: StreamBuilder<DateTime>(
                stream: _newEventBloc.fromDate,
                builder: (context, snapshot) {
                  return Text(parseDateTime(snapshot.data) ?? 'Current');
                }
              ),
              onPressed: () => pickDate(context).then((val){
                _newEventBloc.newFromDate(val);
              }),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('To:'),
            FlatButton(
              child: StreamBuilder<Object>(
                stream: _newEventBloc.toDate,
                builder: (context, snapshot) {
                  return Text(parseDateTime(snapshot.data) ?? 'Current');
                }
              ),
              onPressed: () => pickDate(context).then((val){
                _newEventBloc.newToDate(val);
              }),
            ),
          ],
        )
      ],
    );
  }
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