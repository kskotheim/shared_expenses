import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/new_event_bloc.dart';
import 'package:shared_expenses/src/ui/group_page/new_event/bill_section.dart';
import 'package:shared_expenses/src/ui/group_page/new_event/payment_section.dart';

class NewEventDialog extends StatelessWidget {
  final NewEventBloc newEventBloc;
  final GroupBloc groupBloc;

  NewEventDialog({this.groupBloc, this.newEventBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: newEventBloc,
      child: Dialog(
        child: Container(
          height: 400.0,
          width: 200.0,
          child: StreamBuilder<bool>(
            stream: newEventBloc.showConfirmationStream,
            builder: (context, showConfirmSnapshot) {
              if (!showConfirmSnapshot.hasData || !showConfirmSnapshot.data) {
                return StreamBuilder<BillOrPaymentSection>(
                  stream: newEventBloc.selectedOption,
                  builder: (context, snapshot) {
                    Widget sectionToShow = Container();
                    if (snapshot.data is ShowBillSection)
                      sectionToShow = BillSection(
                        categories: groupBloc.billTypes,
                      );
                    else if (snapshot.data is ShowPaymentSection)
                      sectionToShow = PaymentSection(
                        users: groupBloc.usersInAccount,
                      );

                    return ListView(
                      children: <Widget>[
                        Container(
                          height: 80.0,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  color: !(snapshot.data is ShowBillSection)
                                      ? Colors.grey.shade200
                                      : null,
                                  child: InkWell(
                                    child: Center(child: Text('Bill')),
                                    onTap: newEventBloc.showBillSection,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  color: !(snapshot.data is ShowPaymentSection)
                                      ? Colors.grey.shade200
                                      : null,
                                  child: InkWell(
                                    child: Center(child: Text('Payment')),
                                    onTap: newEventBloc.showPaymentSection,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        sectionToShow,
                      ],
                    );
                  },
                );
              } else {
                //return the confirmation dialog
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: newEventBloc.selectedEventDetails() +
                      <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FlatButton(
                              child: Text('Back'),
                              onPressed: newEventBloc.hideConfirmation,
                            ),
                            FlatButton(
                              onPressed: () => newEventBloc
                                  .submitInfo()
                                  .then((_) => Navigator.pop(context)),
                              child: Text('Submit'),
                            )
                          ],
                        )
                      ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
