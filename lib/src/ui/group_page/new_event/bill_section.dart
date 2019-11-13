import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/new_event_bloc.dart';
import 'package:shared_expenses/src/res/models/user.dart';
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
        SubmitBillButton(),
      ],
    );
  }
}

class AdminSelectUserSection extends StatefulWidget {
  final List<User> users;
  AdminSelectUserSection({this.users});

  @override
  _AdminSelectUserSectionState createState() => _AdminSelectUserSectionState();
}

class _AdminSelectUserSectionState extends State<AdminSelectUserSection> {
  bool showUserSelectionOption = false;

  @override
  Widget build(BuildContext context) {
    NewEventBloc newEventBloc = BlocProvider.of<NewEventBloc>(context);

    Widget usersList = Container(
      child: StreamBuilder<String>(
        stream: newEventBloc.adminSelectedUser,
        builder: (context, snapshot) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Paid By:'),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.users.length,
                itemBuilder: (context, i) => FlatButton(
                  color: snapshot.data == widget.users[i].userId
                      ? Colors.greenAccent.shade200
                      : null,
                  onPressed: () =>
                      newEventBloc.adminSelectUser(widget.users[i].userId),
                  child: Text(widget.users[i].userName),
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 100.0),
              ),
            ],
          );
        },
      ),
    );
    if (showUserSelectionOption) {
      return usersList;
    } else {
      return FlatButton(child: Text('(Paid By You)'), onPressed: () => setState(() =>showUserSelectionOption = true));
    }
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
              GridView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) => FlatButton(
                  color: snapshot.data == categories[i]
                      ? Colors.blueGrey.shade200
                      : null,
                  onPressed: () => newEventBloc.selectType(categories[i]),
                  child: Text(categories[i]),
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 100.0),
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
                  ));
            }),
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
          return FlatButton(
            child: Text('Submit'),
            onPressed: (snapshot.hasData && snapshot.data)
                ? newEventBloc.showConfirmation
                : null,
          );
        });
  }
}
