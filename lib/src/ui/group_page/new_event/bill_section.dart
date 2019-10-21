import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/new_event_bloc.dart';
import 'package:shared_expenses/src/res/util.dart';

class BillSection extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);


    return Column(
      children: <Widget>[
        //type
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Type: '),
            StreamBuilder<String>(
              stream: newEventBloc.selectedType,
              builder: (context, snapshot) {
                return DropdownButton(
                  value: snapshot.data,
                  items: newEventBloc.groupBloc.billTypeMenuItems,
                  onChanged: newEventBloc.selectType,
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
              stream: newEventBloc.billAmount,
              builder: (context, snapshot) {
                return Container(
                    width: 100.0,
                    child: TextField(
                      onChanged: newEventBloc.newBillAmount,
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
                stream: newEventBloc.fromDate,
                builder: (context, snapshot) {
                  return Text(parseDateTime(snapshot.data) ?? 'Current');
                }
              ),
              onPressed: () => pickDate(context).then((val){
                newEventBloc.newFromDate(val);
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
                stream: newEventBloc.toDate,
                builder: (context, snapshot) {
                  return Text(parseDateTime(snapshot.data) ?? 'Current');
                }
              ),
              onPressed: () => pickDate(context).then((val){
                newEventBloc.newToDate(val);
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
