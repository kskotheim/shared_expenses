import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/new_event_bloc.dart';
import 'package:shared_expenses/src/res/models/user.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/res/util.dart';

class PaymentSection extends StatelessWidget {
  final List<User> users;

  PaymentSection({this.users});

  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);

    return Column(
      children: <Widget>[
        newEventBloc.groupBloc.isGroupOwner
            ? FromUserSection(
                users: users,
              )
            : Container(),
        ToUserSection(
          users: users,
        ),
        AmountSection(),
        PaymentNotesSection(),
        Container(height: 30.0,),
        SubmitPaymentButton(),
        Container(height: 30.0,),
      ],
    );
  }
}

class FromUserSection extends StatelessWidget {
  final List<User> users;

  FromUserSection({this.users});

  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);

    return StreamBuilder<bool>(
        stream: newEventBloc.adminModifyingFromUser,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return FlatButton(
                child: Text('(Payment From You)'),
                onPressed: newEventBloc.modifyFromUser);
          }
          return Container(
            child: StreamBuilder<String>(
              stream: newEventBloc.adminSelectedUser,
              builder: (context, snapshot) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("From:"),
                    SEGridView(
                      itemCount: users.length,
                      itemBuilder: (context, i) => FlatButton(
                        color: snapshot.data == users[i].userId
                            ? Colors.greenAccent.shade200
                            : null,
                        onPressed: () =>
                            newEventBloc.adminSelectUser(users[i].userId),
                        child: Text(users[i].userName),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        });
  }
}

class ToUserSection extends StatelessWidget {
  final List<User> users;

  ToUserSection({this.users});

  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);

    Widget usersList = Container(
      child: StreamBuilder<String>(
        stream: newEventBloc.selectedUser,
        builder: (context, snapshot) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('To:'),
              SEGridView(
                itemCount: users.length,
                itemBuilder: (context, i) => FlatButton(
                  color: snapshot.data == users[i].userId
                      ? Colors.greenAccent.shade200
                      : null,
                  onPressed: () => newEventBloc.selectUser(users[i].userId),
                  child: Text(users[i].userName),
                ),
              ),
            ],
          );
        },
      ),
    );

    return usersList;
  }
}

class PaymentNotesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Notes:'),
        StreamBuilder<String>(
            stream: newEventBloc.paymentNotes,
            builder: (context, snapshot) {
              return Container(
                width: 100.0,
                child: TextField(
                  onChanged: newEventBloc.newPaymentNote,
                ),
              );
            })
      ],
    );
  }
}

class AmountSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Amount:'),
        StreamBuilder<double>(
            stream: newEventBloc.billAmount,
            builder: (context, snapshot) {
              return Container(
                width: 100.0,
                child: TextField(
                  onChanged: newEventBloc.newBillAmount,
                  keyboardType: TextInputType.number,
                ),
              );
            })
      ],
    );
  }
}

class SubmitPaymentButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);
    return StreamBuilder<bool>(
        stream: newEventBloc.paymentPageValidated,
        builder: (context, snapshot) {
          return RaisedButton(
            child: Text('Submit'),
            color: Style.lightBrown,
            disabledColor: Colors.grey.shade200,
            shape: Style.roundedButtonBorder,
            onPressed: (snapshot.hasData && snapshot.data)
                ? newEventBloc.showConfirmation
                : null,
          );
        });
  }
}
