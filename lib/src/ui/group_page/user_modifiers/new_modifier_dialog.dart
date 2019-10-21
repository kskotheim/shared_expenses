import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/new_user_modifier_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/res/util.dart';

class NewModifierDialog extends StatelessWidget {
  final GroupBloc groupBloc;
  final NewUserModifierBloc userModifierBloc;

  NewModifierDialog({this.groupBloc, this.userModifierBloc}) : assert(groupBloc != null);

  @override
  Widget build(BuildContext context) {

    return BlocProvider<NewUserModifierBloc>(
      bloc: userModifierBloc,
      child: Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'New User Modifier',
              style: Style.subTitleTextStyle,
            ),

            // select user
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('User: '),
                StreamBuilder<String>(
                    stream: userModifierBloc.selectedUser,
                    builder: (context, snapshot) {
                      return DropdownButton(
                        items: groupBloc.userMenuItems,
                        onChanged: userModifierBloc.selectUser,
                        value: snapshot.data,
                      );
                    })
              ],
            ),

            // share amt modifier

            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Shares: '),
                Container(
                  width: 100.0,
                  child: StreamBuilder<num>(
                    stream: userModifierBloc.shares,
                    builder: (context, shapshot) {
                      return TextField(
                        keyboardType: TextInputType.number,
                        onChanged: userModifierBloc.setShares,
                        
                      );
                    },
                  ),
                )
              ],
            ),

            // all dates or select dates

            StreamBuilder<bool>(
              stream: userModifierBloc.allDatesCheckbox,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                return Column(
                  children: <Widget>[
                    Container(
                      width: 200.0,
                      child: CheckboxListTile(
                        value: snapshot.data,
                        onChanged: userModifierBloc.setAllDatesCheckbox,
                        title: Text('All Dates'),
                      ),
                    ),
                    !snapshot.data ? SelectDatesSection() : Container(),
                  ],
                );
              },
            ),

            // all categories or select categories

            StreamBuilder<bool>(
              stream: userModifierBloc.allCategoriesCheckbox,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                return Column(
                  children: <Widget>[
                    Container(
                      width: 200.0,
                      child: CheckboxListTile(
                        value: snapshot.data,
                        onChanged: userModifierBloc.setAllCategoriesCheckbox,
                        title: Text('All Categories'),
                      ),
                    ),
                    !snapshot.data
                        ? SelectCategoriesSection(
                            groupBloc: groupBloc,
                          )
                        : Container(),
                  ],
                );
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Text('cancel'),
                  onPressed: () => Navigator.pop(context),
                ),

                FlatButton(
                  child: Text('submit'),
                  onPressed: () async {
                    String result = await userModifierBloc.submitModifier();
                    print(result);
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          ],
        ),
      ),
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
      children: <Widget>[
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
