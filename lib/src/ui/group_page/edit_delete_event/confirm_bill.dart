import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/edit_delete_dialog_bloc.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/res/models/event.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/res/util.dart';

class ConfirmDeleteBill extends StatelessWidget {
  final Bill bill;

  ConfirmDeleteBill({this.bill}) : assert(bill != null);

  @override
  Widget build(BuildContext context) {
    EditDeleteDialogBloc editDeleteEventBloc =
        BlocProvider.of<EditDeleteDialogBloc>(context);
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

class ConfirmUpdateBill extends StatelessWidget {
  final Bill bill;

  ConfirmUpdateBill({this.bill}) : assert(bill != null);

  @override
  Widget build(BuildContext context) {
    EditDeleteDialogBloc editDeleteEventBloc =
        BlocProvider.of<EditDeleteDialogBloc>(context);
    GroupBloc groupBloc = editDeleteEventBloc.groupBloc;

    return Center(
      child: Padding(
        padding: Style.eventsViewPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Confirm Update Bill',
              style: Style.subTitleTextStyle,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Amount: ${bill.amount}'),
                Text('Category: ${bill.type}'),
                Text('Paid By: ${groupBloc.userName(bill.paidByUserId)}'),
                Text('From: ${parseDateTime(bill.fromDate)}'),
                Text('To: ${parseDateTime(bill.toDate)}'),
                Text('Notes: ${bill.notes}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                  onPressed: editDeleteEventBloc.initialized,
                ),
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                  onPressed: () => editDeleteEventBloc
                      .updateBill(bill)
                      .then((_) => Navigator.pop(context)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
