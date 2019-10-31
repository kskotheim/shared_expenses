import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/new_user_modifier_bloc.dart';
import 'package:shared_expenses/src/res/models/user.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/res/util.dart';

class NewModifierDialog extends StatelessWidget {
  final GroupBloc groupBloc;
  final NewUserModifierBloc userModifierBloc;

  NewModifierDialog({this.groupBloc, this.userModifierBloc})
      : assert(groupBloc != null);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NewUserModifierBloc>(
      bloc: userModifierBloc,
      child: Dialog(
        child: StreamBuilder<ModifierDialogPageToShow>(
          stream: userModifierBloc.modifierDialogPageToShow,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data is ModifierDialogMain) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'New User Modifier',
                    style: Style.subTitleTextStyle,
                  ),
                  SelectUserSection(
                    users: groupBloc.usersInAccount,
                  ),
                  ShareAmountSection(),
                  DatesSection(),
                  CategoriesSection(),
                  CancelOrSubmitButton(),
                ],
              );
            } else if (snapshot.data is ModifierDialogDates) {
              return SelectDatesSection();

              //select dates section
            } else if (snapshot.data is ModifierDialogCategories) {
              return SelectCategoriesSection(
                groupBloc: groupBloc,
              );
            }
          },
        ),
      ),
    );
  }
}

class SelectUserSection extends StatelessWidget {
  final List<User> users;

  SelectUserSection({this.users}) : assert(users != null);

  @override
  Widget build(BuildContext context) {
    NewUserModifierBloc newModifierBloc =
        BlocProvider.of<NewUserModifierBloc>(context);

    Widget usersList = Container(
      child: StreamBuilder<String>(
        stream: newModifierBloc.selectedUser,
        builder: (context, snapshot) {
          return GridView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, i) => FlatButton(
              color: snapshot.data == users[i].userId
                  ? Colors.greenAccent.shade200
                  : null,
              onPressed: () => newModifierBloc.selectUser(users[i].userId),
              child: Text(users[i].userName),
            ),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 100.0),
          );
        },
      ),
    );

    return usersList;
  }
}

class ShareAmountSection extends StatelessWidget {
  TextEditingController _sharesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    NewUserModifierBloc newModifierBloc =
        BlocProvider.of<NewUserModifierBloc>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Shares: '),
        Container(
          width: 100.0,
          child: StreamBuilder<String>(
            stream: newModifierBloc.shares,
            builder: (context, snapshot) {
              _sharesController.value = _sharesController.value.copyWith(text: snapshot.data.toString());
              return TextField(
                keyboardType: TextInputType.number,
                onChanged: newModifierBloc.setShares,
                controller: _sharesController,
              );
            },
          ),
        )
      ],
    );
  }
}

class DatesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NewUserModifierBloc userModifierBloc =
        BlocProvider.of<NewUserModifierBloc>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 200.0,
          child: CheckboxListTile(
            value: true,
            onChanged: userModifierBloc.showDatesPage,
            title: Text(userModifierBloc.getDatesString),
          ),
        ),
      ],
    );
  }
}

class SelectCategoriesSection extends StatelessWidget {
  final GroupBloc groupBloc;

  SelectCategoriesSection({this.groupBloc}) : assert(groupBloc != null);

  @override
  Widget build(BuildContext context) {
    NewUserModifierBloc userModifierBloc =
        BlocProvider.of<NewUserModifierBloc>(context);

    return StreamBuilder<Map<String, bool>>(
        stream: userModifierBloc.selectedCategoriesStream,
        builder: (context, newSnapshot) {
          if (!newSnapshot.hasData) return CircularProgressIndicator();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: groupBloc.billTypes.map((String type) {
                  return Container(
                    width: 200.0,
                    child: CheckboxListTile(
                      value: newSnapshot.data[type],
                      onChanged: (val) =>
                          userModifierBloc.selectCategory([type, val]),
                      title: Text(type),
                    ),
                  );
                }).toList(),
              ),
              FlatButton(
                child: Text('Done'),
                onPressed: userModifierBloc.showMainPage,
              )
            ],
          );
        });
  }
}

class SelectDatesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NewUserModifierBloc userModifierBloc =
        BlocProvider.of<NewUserModifierBloc>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Select User Modifier Dates',
          style: Style.subTitleTextStyle,
        ),

        //datesApplied
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('From:'),
            FlatButton(
              child: StreamBuilder<DateTime>(
                  stream: userModifierBloc.fromDate,
                  builder: (context, snapshot) {
                    return Text(parseDateTime(snapshot.data) ?? 'Beginning');
                  }),
              onPressed: () => pickDate(context).then((val) {
                userModifierBloc.newFromDate(val);
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
                  stream: userModifierBloc.toDate,
                  builder: (context, snapshot) {
                    return Text(parseDateTime(snapshot.data) ?? 'End');
                  }),
              onPressed: () => pickDate(context).then((val) {
                userModifierBloc.newToDate(val);
              }),
            ),
          ],
        ),
        FlatButton(
          child: Text('Done'),
          onPressed: userModifierBloc.showMainPage,
        ),
      ],
    );
  }
}

Future<DateTime> pickDate(BuildContext context) {
  return showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.parse("20000101"),
    lastDate: DateTime.parse("21001231"),
  );
}

class CategoriesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NewUserModifierBloc userModifierBloc =
        BlocProvider.of<NewUserModifierBloc>(context);
    return Column(
      children: <Widget>[
        Container(
          width: 200.0,
          child: CheckboxListTile(
            value: true,
            onChanged: userModifierBloc.showCategories,
            title: Text(userModifierBloc.getCategoriesString),
          ),
        ),
      ],
    );
  }
}

class CancelOrSubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NewUserModifierBloc userModifierBloc =
        BlocProvider.of<NewUserModifierBloc>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          child: Text('cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        StreamBuilder<bool>(
          stream: userModifierBloc.modifierValidated,
          builder: (context, snapshot) {
            return FlatButton(
              child: Text('submit'),
              onPressed: (snapshot.hasData && snapshot.data)
                  ? () => userModifierBloc
                      .submitModifier()
                      .then((_) => Navigator.pop(context))
                  : null,
            );
          }
        ),
      ],
    );
  }
}
