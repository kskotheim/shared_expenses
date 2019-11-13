
import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/edit_delete_dialog_bloc.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/res/util.dart';

class SelectSpecificBillOrPaymentWidget extends StatelessWidget {
  final GroupBloc groupBloc;

  SelectSpecificBillOrPaymentWidget({this.groupBloc})
      : assert(groupBloc != null);

  @override
  Widget build(BuildContext context) {
    EditDeleteDialogBloc editDeleteEventBloc =
        BlocProvider.of<EditDeleteDialogBloc>(context);
    return StreamBuilder<EditOptionSelected>(
      stream: editDeleteEventBloc.billOrPaymentSelected,
      builder: (context, snapshot) {
        Widget selectedWidget = Container();

        if (snapshot.data is ShowBills) {
          selectedWidget = ListView(
            shrinkWrap: true,
            children: editDeleteEventBloc.theBills
                .map((bill) => ListTile(
                      title: Text(
                        '\$${bill.amount} ${bill.type} bill paid by ${groupBloc.userName(bill.paidByUserId)}',
                        style: Style.regularTextStyle,
                      ),
                      leading:
                          DateIcon(bill.createdAt.month, bill.createdAt.day),
                      onTap: () => editDeleteEventBloc.editBill(bill),
                    ))
                .toList(),
          );
        }
        if (snapshot.data is ShowPayments) {
          selectedWidget = ListView(
            shrinkWrap: true,
            children: editDeleteEventBloc.thePayments
                .map((payment) => ListTile(
                      title: Text(
                        '\$${payment.amount} payment from ${groupBloc.userName(payment.fromUserId)} to ${groupBloc.userName(payment.toUserId)}',
                        style: Style.regularTextStyle,
                      ),
                      onTap: () => editDeleteEventBloc.editPayment(payment),
                      leading: DateIcon(
                          payment.createdAt.month, payment.createdAt.day),
                    ))
                .toList(),
          );
        }

        return ListView(
          children: <Widget>[
            Container(
              height: 80.0,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: !(snapshot.data is ShowBills)
                          ? Colors.grey.shade200
                          : null,
                      child: InkWell(
                        child: Center(
                            child: Text(
                          'Bill',
                          style: Style.regularTextStyle,
                        )),
                        onTap: editDeleteEventBloc.selectBill,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: !(snapshot.data is ShowPayments)
                          ? Colors.grey.shade200
                          : null,
                      child: InkWell(
                        child: Center(
                            child: Text(
                          'Payment',
                          style: Style.regularTextStyle,
                        )),
                        onTap: editDeleteEventBloc.selectPayment,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 320.0,
              child: selectedWidget,
            )
          ],
        );
      },
    );
  }
}
