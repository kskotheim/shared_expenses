import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/edit_delete_dialog_bloc.dart';
import 'package:shared_expenses/src/bloc/edit_event_bloc.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/res/models/event.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/res/util.dart';

class EditBill extends StatelessWidget {
  final Bill bill;
  final EditDeleteDialogBloc editDeleteEventBloc;
  EditEventBloc _editEventBloc;
  TextEditingController _billAmountController = TextEditingController();
  TextEditingController _billNotesController = TextEditingController();
  GroupBloc _groupBloc;

  EditBill({this.bill, this.editDeleteEventBloc}) {
    assert(bill != null, editDeleteEventBloc != null);
    _editEventBloc = editDeleteEventBloc.editEventBloc;
    _groupBloc = editDeleteEventBloc.groupBloc;
  }

  @override
  Widget build(BuildContext context) {
    EditDeleteDialogBloc editDeleteEventBloc =
        BlocProvider.of<EditDeleteDialogBloc>(context);
    _editEventBloc.loadEvent();
    
    return Padding(
      padding: Style.eventsViewPadding,
      child: Center(
        child: ListView(
          children: <Widget>[
            Text(
              'Editing Bill created by ${_groupBloc.userName(bill.paidByUserId)} on ${parseDateTime(bill.createdAt)}',
              style: Style.subTitleTextStyle,
              textAlign: TextAlign.center,
            ),

            Container(
              height: 20.0,
            ),
            Text('Category: ', style: Style.regularTextStyle),
            // select category section
            StreamBuilder<String>(
              stream: _editEventBloc.category,
              builder: (context, snapshot) {
                return SEGridView(
                  itemCount: _groupBloc.billTypes.length,
                  itemBuilder: (context, i) => FlatButton(
                    color: snapshot.data == _groupBloc.billTypes[i]
                        ? Colors.blueGrey.shade200
                        : null,
                    onPressed: () =>
                        _editEventBloc.updateCategory(_groupBloc.billTypes[i]),
                    child: Text(_groupBloc.billTypes[i]),
                  ),
                );
              },
            ),

            Container(
              height: 20.0,
            ),

            // Paid by user section
            Text('Paid by:', style: Style.regularTextStyle),
            StreamBuilder<String>(
              stream: _editEventBloc.paidByUser,
              builder: (context, snapshot) {
                return SEGridView(
                  itemCount: _groupBloc.usersInAccount.length,
                  itemBuilder: (context, i) => FlatButton(
                    color: snapshot.data == _groupBloc.usersInAccount[i].userId
                        ? Colors.blueGrey.shade200
                        : null,
                    onPressed: () => _editEventBloc
                        .updatePaidByUser(_groupBloc.usersInAccount[i].userId),
                    child: Text(_groupBloc.usersInAccount[i].userName),
                  ),
                );
              },
            ),

            Container(
              height: 20.0,
            ),

            // amount section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('\$', style: Style.regularTextStyle),
                StreamBuilder<num>(
                  stream: _editEventBloc.amount,
                  builder: (context, snapshot) {
                    _billAmountController.value = _billAmountController.value
                        .copyWith(text: snapshot.data.toString());
                    return Container(
                      width: 100.0,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (amt) =>
                            _editEventBloc.newAmount(double.parse(amt)),
                        style: Style.regularTextStyle,
                        controller: _billAmountController,
                      ),
                    );
                  },
                ),
              ],
            ),

            Container(
              height: 10.0,
            ),

            // notes section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Notes:',
                  style: Style.regularTextStyle,
                ),
                StreamBuilder<String>(
                  stream: _editEventBloc.notes,
                  builder: (context, snapshot) {
                    _billNotesController.value = _billNotesController.value
                        .copyWith(text: snapshot.data);
                    return Container(
                      width: 100.0,
                      child: TextField(
                        controller: _billNotesController,
                        onChanged: _editEventBloc.updateNotes,
                        style: Style.regularTextStyle,
                      ),
                    );
                  },
                )
              ],
            ),

            DatesSection(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: editDeleteEventBloc.initialized,
                ),
                StreamBuilder<bool>(
                  stream: _editEventBloc.updateValid,
                  builder: (context, snapshot) {
                    if(!snapshot.hasData) return Container();
                    return IconButton(
                      icon: Icon(
                        Icons.check,
                        color: snapshot.data ? Colors.green : Colors.grey,
                      ),
                      onPressed: snapshot.data ? () => editDeleteEventBloc.confirmUpdateBill(_editEventBloc.updatedBill) : null,
                    );
                  }
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () => editDeleteEventBloc.confirmDeleteBill(bill),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class DatesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    EditDeleteDialogBloc editDeleteEventBloc = BlocProvider.of<EditDeleteDialogBloc>(context);
    EditEventBloc editEventBloc = editDeleteEventBloc.editEventBloc;

    return Column(
      children: <Widget>[
        //datesApplied
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('From:'),
            FlatButton(
              child: StreamBuilder<DateTime>(
                  stream: editEventBloc.fromDate,
                  builder: (context, snapshot) {
                    return Text(parseDateTime(snapshot.data) ?? 'Current');
                  }),
              onPressed: () => pickDate(context).then((val) {
                editEventBloc.updateFromDate(val);
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
                  stream: editEventBloc.toDate,
                  builder: (context, snapshot) {
                    return Text(parseDateTime(snapshot.data) ?? 'Current');
                  }),
              onPressed: () => pickDate(context).then((val) {
                editEventBloc.updateToDate(val);
              }),
            ),
          ],
        )
      ],
    );
  }
}
