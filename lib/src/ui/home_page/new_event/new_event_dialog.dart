import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/new_event_bloc.dart';
import 'package:shared_expenses/src/ui/home_page/new_event/bill_section.dart';
import 'package:shared_expenses/src/ui/home_page/new_event/payment_section.dart';

class NewEventDialog extends StatelessWidget {
  NewEventBloc _newEventBloc;
  final GroupBloc groupBloc;

  NewEventDialog({this.groupBloc});

  @override
  Widget build(BuildContext context) {
    _newEventBloc = NewEventBloc(groupBloc: groupBloc);

    return BlocProvider(
      bloc: _newEventBloc,
      child: Dialog(
        child: StreamBuilder<String>(
            stream: _newEventBloc.optionSelected,
            builder: (context, snapshot) {
              return Column(
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
                        items: _billOrPaymentMenuItems,
                        value: snapshot.data,
                        onChanged: (val) {
                          if (val == NewEventBloc.BILL) {
                            _newEventBloc.selectBill();
                          } else {
                            _newEventBloc.selectPayment();
                          }
                        },
                      )
                    ],
                  ),
                  snapshot.data == null
                      ? Container()
                      : snapshot.data == NewEventBloc.BILL
                          ? BillSection()
                          : PaymentSection(),
                  FlatButton(
                    child: Text('Submit'),
                    onPressed: () => _newEventBloc.submitInfo().then((_) => Navigator.pop(context)),
                  )
                ],
              );
            }),
      ),
    );
  }

  final List<DropdownMenuItem> _billOrPaymentMenuItems = [
    DropdownMenuItem(
      child: Text('Payment'),
      value: NewEventBloc.PAYMENT,
    ),
    DropdownMenuItem(
      value: NewEventBloc.BILL,
      child: Text('Bill'),
    ),
  ];
}
