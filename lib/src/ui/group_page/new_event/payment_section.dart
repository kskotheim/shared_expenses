import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/new_event_bloc.dart';

class PaymentSection extends StatelessWidget {
  NewEventBloc _newEventBloc;
  @override
  Widget build(BuildContext context) {
    _newEventBloc = BlocProvider.of<NewEventBloc>(context);

    return Column(
      children: <Widget>[
        //to user
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('To: '),
            StreamBuilder<String>(
              stream: _newEventBloc.selectedUser,
              builder: (context, snapshot) {
                return DropdownButton(
                  items: _newEventBloc.userMenuItems,
                  value: snapshot.data,
                  onChanged: _newEventBloc.selectUser
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
                  stream: _newEventBloc.billAmount,
                  builder: (context, snapshot) {
                    return TextField(
                      keyboardType: TextInputType.number,
                      onChanged: _newEventBloc.newBillAmount,
                    );
                  }
                )),
          ],
        ),
      ],
    );
  }
}
