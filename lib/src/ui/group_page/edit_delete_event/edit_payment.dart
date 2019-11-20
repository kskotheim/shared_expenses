import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/edit_delete_dialog_bloc.dart';
import 'package:shared_expenses/src/bloc/edit_event_bloc.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/res/models/event.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/res/util.dart';

class EditPayment extends StatelessWidget {
  final Payment payment;
  final EditDeleteDialogBloc editDeleteEventBloc;
  EditEventBloc _editEventBloc;
  GroupBloc _groupBloc;
  TextEditingController _paymentAmountController = TextEditingController();
  TextEditingController _notesController = TextEditingController();

  EditPayment({this.payment, this.editDeleteEventBloc}) {
    assert(payment != null, editDeleteEventBloc != null);
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
                'Editing payment made by ${_groupBloc.userName(payment.fromUserId)} to ${_groupBloc.userName(payment.toUserId)} on ${parseDateTime(payment.createdAt)}',
                style: Style.subTitleTextStyle),

            Container(
              height: 20.0,
            ),

            // from user section
            Text('From:', style: Style.regularTextStyle),
            StreamBuilder<String>(
              stream: _editEventBloc.fromUser,
              builder: (context, snapshot) {
                return SEGridView(
                  itemCount: _groupBloc.usersInAccount.length,
                  itemBuilder: (context, i) => FlatButton(
                    color: snapshot.data == _groupBloc.usersInAccount[i].userId
                        ? Colors.blueGrey.shade200
                        : null,
                    onPressed: () => _editEventBloc
                        .updateFromUser(_groupBloc.usersInAccount[i].userId),
                    child: Text(_groupBloc.usersInAccount[i].userName),
                  ),
                );
              },
            ),

            Container(
              height: 20.0,
            ),

            // to user section
            Text('To:', style: Style.regularTextStyle),
            StreamBuilder<String>(
              stream: _editEventBloc.toUser,
              builder: (context, snapshot) {
                return SEGridView(
                  itemCount: _groupBloc.usersInAccount.length,
                  itemBuilder: (context, i) => FlatButton(
                    color: snapshot.data == _groupBloc.usersInAccount[i].userId
                        ? Colors.blueGrey.shade200
                        : null,
                    onPressed: () => _editEventBloc
                        .updateToUser(_groupBloc.usersInAccount[i].userId),
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
                    _paymentAmountController.value = _paymentAmountController
                        .value
                        .copyWith(text: snapshot.data.toString());
                    return Container(
                      width: 100.0,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (amt) =>
                            _editEventBloc.newAmount(double.parse(amt)),
                        style: Style.regularTextStyle,
                        controller: _paymentAmountController,
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
                    _notesController.value =
                        _notesController.value.copyWith(text: snapshot.data);
                    return Container(
                      width: 100.0,
                      child: TextField(
                        controller: _notesController,
                        onChanged: _editEventBloc.updateNotes,
                        style: Style.regularTextStyle,
                      ),
                    );
                  },
                )
              ],
            ),

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
                      onPressed: snapshot.data ? () => editDeleteEventBloc.confirmUpdatePayment(_editEventBloc.updatedPayment) : null,
                    );
                  }
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () =>
                      editDeleteEventBloc.confirmDeletePayment(payment),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
