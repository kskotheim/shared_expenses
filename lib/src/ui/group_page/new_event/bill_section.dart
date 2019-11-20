import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/new_event_bloc.dart';
import 'package:shared_expenses/src/res/models/user.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/res/util.dart';

class BillSection extends StatelessWidget {
  final List<String> categories;
  final List<User> users;

  BillSection({this.categories, this.users})
      : assert(categories != null, users != null);

  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);

    return Column(
      children: <Widget>[
        newEventBloc.groupBloc.isGroupOwner
            ? AdminSelectUserSection(
                users: users,
              )
            : Container(),
        SelectCategorySection(
          categories: categories,
        ),
        AmountSection(),
        BillNotesSection(),
        DatesSection(),
        Container(
          height: 30.0,
        ),
        SubmitBillButton(),
        Container(
          height: 30.0,
        ),
      ],
    );
  }
}

class AdminSelectUserSection extends StatelessWidget {
  final List<User> users;
  AdminSelectUserSection({this.users});
  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);

    return StreamBuilder<bool>(
      stream: newEventBloc.adminModifyingFromUser,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FlatButton(
              child: Text('(Paid By You)'),
              onPressed: newEventBloc.modifyFromUser);
        }
        return Container(
          child: StreamBuilder<String>(
            stream: newEventBloc.adminSelectedUser,
            builder: (context, snapshot) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Paid By:'),
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
      },
    );
  }
}

class SelectCategorySection extends StatelessWidget {
  final List<String> categories;

  SelectCategorySection({this.categories});

  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);

    Widget categoryList = Container(
      child: StreamBuilder<String>(
        stream: newEventBloc.selectedType,
        builder: (context, snapshot) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Category:'),
              SEGridView(
                itemCount: categories.length,
                itemBuilder: (context, i) => FlatButton(
                  color: snapshot.data == categories[i]
                      ? Colors.blueGrey.shade200
                      : null,
                  onPressed: () => newEventBloc.selectType(categories[i]),
                  child: Text(categories[i]),
                ),
              ),
            ],
          );
        },
      ),
    );

    return categoryList;
  }
}

class AmountSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Amount: '),
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
          },
        ),
      ],
    );
  }
}

class BillNotesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Notes:'),
        StreamBuilder<String>(
            stream: newEventBloc.billNotes,
            builder: (context, snapshot) {
              return Container(
                width: 100.0,
                child: TextField(
                  onChanged: newEventBloc.newBillNote,
                ),
              );
            })
      ],
    );
  }
}

class DatesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);

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
                  stream: newEventBloc.fromDate,
                  builder: (context, snapshot) {
                    return Text(parseDateTime(snapshot.data) ?? 'Current');
                  }),
              onPressed: () => pickDate(context).then((val) {
                newEventBloc.newFromDate(val);
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
                  stream: newEventBloc.toDate,
                  builder: (context, snapshot) {
                    return Text(parseDateTime(snapshot.data) ?? 'Current');
                  }),
              onPressed: () => pickDate(context).then((val) {
                newEventBloc.newToDate(val);
              }),
            ),
          ],
        )
      ],
    );
  }
}

class SubmitBillButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);
    return StreamBuilder<bool>(
      stream: newEventBloc.billPageValidated,
      builder: (context, snapshot) {
        return RaisedButton(
          color: Style.lightGreen,
          disabledColor: Colors.grey.shade200,
          shape: Style.roundedButtonBorder,
          child: Text('Submit'),
          onPressed: (snapshot.hasData && snapshot.data)
              ? newEventBloc.showConfirmation
              : null,
        );
      },
    );
  }
}
