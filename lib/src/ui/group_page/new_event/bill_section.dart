import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/new_event_bloc.dart';
import 'package:shared_expenses/src/res/util.dart';

class BillSection extends StatelessWidget {

  final List<String> categories;

  BillSection({this.categories}) : assert(categories != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SelectCategorySection(categories: categories,),
        AmountSection(),
        BillNotesSection(),
        DatesSection(),
        SubmitBillButton(),
      ],
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
          return GridView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, i) => FlatButton(
              color: snapshot.data == categories[i]
                  ? Colors.blueGrey.shade200
                  : null,
              onPressed: () => newEventBloc.selectUser(categories[i]),
              child: Text(categories[i]),
            ),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 100.0),
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
                ? () => newEventBloc.submitInfo().then((_) => Navigator.pop(context))
                : null,
          );
        });
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
