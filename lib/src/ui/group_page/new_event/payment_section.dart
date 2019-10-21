import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/new_event_bloc.dart';

class PaymentSection extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);

    return Column(
      children: <Widget>[
        //to user
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('To: '),
            StreamBuilder<String>(
              stream: newEventBloc.selectedUser,
              builder: (context, snapshot) {
                return DropdownButton(
                  items: newEventBloc.groupBloc.userMenuItems,
                  value: snapshot.data,
                  onChanged: newEventBloc.selectUser
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
            Container(
                width: 100.0,
                child: StreamBuilder<double>(
                  stream: newEventBloc.billAmount,
                  builder: (context, snapshot) {
                    return TextField(
                      keyboardType: TextInputType.number,
                      onChanged: newEventBloc.newBillAmount,
                    );
                  }
                )),
          ],
        ),

        //notes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Notes: '),
            Container(width: 100.0,
            child: StreamBuilder<String>(
              stream: newEventBloc.paymentNotes,
              builder: (context, snapshot){
                return TextField(
                  keyboardType: TextInputType.text,
                  onChanged: newEventBloc.newPaymentNote,
                );
              },
            ),),
          ],
        )
      ],
    );
  }
}
