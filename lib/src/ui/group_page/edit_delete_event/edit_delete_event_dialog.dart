import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/edit_delete_dialog_bloc.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/ui/group_page/edit_delete_event/confirm_bill.dart';
import 'package:shared_expenses/src/ui/group_page/edit_delete_event/confirm_payment.dart';
import 'package:shared_expenses/src/ui/group_page/edit_delete_event/edit_bill.dart';
import 'package:shared_expenses/src/ui/group_page/edit_delete_event/edit_payment.dart';
import 'package:shared_expenses/src/ui/group_page/edit_delete_event/select_bill_payment.dart';

class EditDeleteEventDialog extends StatelessWidget {
  final EditDeleteDialogBloc editDeleteEventBloc;
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
                  editDeleteEventBloc: editDeleteEventBloc,
                );
              }
              if (snapshot.data is StatusEditPayment) {
                StatusEditPayment status = snapshot.data;
                return EditPayment(
                  payment: status.payment,
                  editDeleteEventBloc: editDeleteEventBloc,
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
              if (snapshot.data is StatusConfirmUpdateBill) {
                StatusConfirmUpdateBill status = snapshot.data;
                return ConfirmUpdateBill(bill: status.bill);
              }
              if (snapshot.data is StatusConfirmUpdatePayment) {
                StatusConfirmUpdatePayment status = snapshot.data;
                return ConfirmUpdatePayment(payment: status.payment);
              }
            },
          ),
        ),
      ),
    );
  }
}
