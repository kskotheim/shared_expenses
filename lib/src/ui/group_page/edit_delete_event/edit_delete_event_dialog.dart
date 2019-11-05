import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/edit_delete_event_bloc.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/res/models/event.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/ui/group_page/edit_delete_event/select_bill_payment.dart';

class EditDeleteEventDialog extends StatelessWidget {
  final EditDeleteEventBloc editDeleteEventBloc;
  final GroupBloc groupBloc;

  EditDeleteEventDialog({this.editDeleteEventBloc, this.groupBloc})
      : assert(editDeleteEventBloc != null, groupBloc != null);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: editDeleteEventBloc,
      child: Dialog(
        child: Container(
          height: 400.0,
          width: 200.0,
          child: StreamBuilder<StatusStreamType>(
            stream: editDeleteEventBloc.statusStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data is StatusUninitialized) {
                return CircularProgressIndicator();
              }
              if (snapshot.data is StatusInitialized) {
                return SelectSpecificBillOrPaymentWidget(groupBloc: groupBloc);
              }
              if (snapshot.data is StatusEditBill) {
                StatusEditBill status = snapshot.data;
                return EditBill(
                  bill: status.bill,
                  groupBloc: groupBloc,
                );
              }
              if (snapshot.data is StatusEditPayment) {
                StatusEditPayment status = snapshot.data;
                return EditPayment(
                  payment: status.payment,
                  groupBloc: groupBloc,
                );
              }
              if (snapshot.data is StatusConfirmDeleteBill) {
                StatusConfirmDeleteBill status = snapshot.data;
                return ConfirmDeleteBill(
                  bill: status.bill,
                );
              }
              if (snapshot.data is StatusConfirmDeletePayment) {
                StatusConfirmDeletePayment status = snapshot.data;
                return ConfirmDeletePayment(
                  payment: status.payment,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class EditBill extends StatelessWidget {
  final Bill bill;
  final GroupBloc groupBloc;

  EditBill({this.bill, this.groupBloc})
      : assert(bill != null, groupBloc != null);

  @override
  Widget build(BuildContext context) {
    EditDeleteEventBloc editDeleteEventBloc =
        BlocProvider.of<EditDeleteEventBloc>(context);
    return Stack(
      children: <Widget>[
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('\$${bill.amount.toStringAsFixed(2)}'),
              Text('${bill.type}'),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
            icon: Icon(Icons.delete),
            color: Colors.red,
            onPressed: () => editDeleteEventBloc.confirmDeleteBill(bill),
          ),
        )
      ],
    );
  }
}

class EditPayment extends StatelessWidget {
  final Payment payment;
  final GroupBloc groupBloc;

  EditPayment({this.payment, this.groupBloc})
      : assert(payment != null, groupBloc != null);

  @override
  Widget build(BuildContext context) {
    EditDeleteEventBloc editDeleteEventBloc =
        BlocProvider.of<EditDeleteEventBloc>(context);
    return Stack(
      children: <Widget>[
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('\$${payment.amount.toStringAsFixed(2)}'),
              Text(
                  'from ${groupBloc.userName(payment.fromUserId)} to ${groupBloc.userName(payment.toUserId)}'),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
            icon: Icon(Icons.delete),
            color: Colors.red,
            onPressed: () => editDeleteEventBloc.confirmDeletePayment(payment),
          ),
        )
      ],
    );
  }
}

class ConfirmDeleteBill extends StatelessWidget {
  final Bill bill;

  ConfirmDeleteBill({this.bill}) : assert(bill != null);

  @override
  Widget build(BuildContext context) {
    EditDeleteEventBloc editDeleteEventBloc =
        BlocProvider.of<EditDeleteEventBloc>(context);
    return Center(
      child: Padding(
        padding: Style.eventsViewPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              'Are you sure you want to delete this bill?',
              style: Style.subTitleTextStyle,
            ),
            Text(
              'This action will be visible to other members of the group',
              style: Style.regularTextStyle,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                  child: Text(
                    'Cancel',
                    style: Style.regularTextStyle,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton(
                  child: Text(
                    'Delete',
                    style: Style.regularTextStyle,
                  ),
                  onPressed: () => editDeleteEventBloc
                      .deleteBill(bill)
                      .then((_) => Navigator.pop(context)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmDeletePayment extends StatelessWidget {
  final Payment payment;

  ConfirmDeletePayment({this.payment}) : assert(payment != null);

  @override
  Widget build(BuildContext context) {
    EditDeleteEventBloc editDeleteEventBloc =
        BlocProvider.of<EditDeleteEventBloc>(context);
    return Center(
      child: Padding(
        padding: Style.eventsViewPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              'Are you sure you want to delete this payment?',
              style: Style.subTitleTextStyle,
            ),
            Text(
              'This action will be visible to other members of the group',
              style: Style.regularTextStyle,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                  child: Text(
                    'Cancel',
                    style: Style.regularTextStyle,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton(
                  child: Text(
                    'Delete',
                    style: Style.regularTextStyle,
                  ),
                  onPressed: () => editDeleteEventBloc
                      .deletePayment(payment)
                      .then((_) => Navigator.pop(context)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
