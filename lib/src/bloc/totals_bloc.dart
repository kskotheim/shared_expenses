import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/user.dart';
import 'package:shared_expenses/src/res/style.dart';

class TotalsBloc implements BlocBase {
  final GroupBloc groupBloc;
  final num screenWidth;
  final Repository repo = Repository();
  StreamSubscription _usersSubscription;
  StreamSubscription _totalsSubscription;

  BehaviorSubject<List<Widget>> _totalsListController =
      BehaviorSubject<List<Widget>>();
  Stream<List<Widget>> get totalsList => _totalsListController.stream;

  BehaviorSubject<Column> _totalsBarGraphController = BehaviorSubject<Column>();
  Stream<Column> get totalsBarGraph => _totalsBarGraphController.stream;

  BehaviorSubject<ListOrBarGraphSelected> _whichTotalsToShowController =
      BehaviorSubject<ListOrBarGraphSelected>();
  Stream<ListOrBarGraphSelected> get whichTotalsToShow =>
      _whichTotalsToShowController.stream;
  void showTotalsList() =>
      _whichTotalsToShowController.sink.add(TotalsListSelected());
  void showTotalsGraph() =>
      _whichTotalsToShowController.sink.add(TotalsGraphSelected());

  List<User> _users;
  Map<String, num> _totals;
  TotalsExporter _totalsExporter;

  TotalsBloc({this.groupBloc, this.screenWidth}) {
    showTotalsList();

    _usersSubscription = groupBloc.usersInAccountStream.listen(_addUsers);

    _totalsSubscription =
        repo.totalsStream(groupBloc.groupId).listen(_addTotals);
  }

  void _addUsers(List<User> users) {
    _users = users;

    _checkAndPropagateTotals();
  }

  void _addTotals(Map<String, num> totals) {
    _totals = totals;

    _checkAndPropagateTotals();
  }

  void _checkAndPropagateTotals() {
    //check if we have users and totals
    if (_users != null && _totals != null) {
      //make totals
      _totalsExporter = TotalsExporter(screenWidth);

      _totals.forEach((id, total) {
        List<User> theUser = _users.where((user) => user.userId == id).toList();
        if (theUser.length == 1) {
          String username = theUser[0].userName ?? 'unnamed user';
          _totalsExporter.addTotal(username, total);
        } else {
          print('couldnt find user $id in account ${groupBloc.groupId}');
        }
      });

      //add totals to sink
      _totalsListController.sink.add(_totalsExporter.getTotals);
      _totalsBarGraphController.sink.add(_totalsExporter.getBarGraph());
    }
    //if not, wait ...
  }

  @override
  void dispose() {
    _totalsListController.close();
    _usersSubscription.cancel();
    _totalsSubscription.cancel();
    _totalsBarGraphController.close();
    _whichTotalsToShowController.close();
  }
}

class TotalsExporter {
  final screenWidth;
  TotalsExporter(this.screenWidth);

  Map<String, num> _totals = {};

  void addTotal(String name, num amount) {
    _totals[name] = amount;
  }

  List<Widget> get getTotals => _totals.entries
      .map(
        (entry) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${entry.key}: \$${entry.value}',
                style: entry.value < -1
                    ? Style.regularTextStyleGreen
                    : entry.value > 1
                        ? Style.regularTextStyleRed
                        : Style.regularTextStyle,
              ),
            )
          ],
        ),
      )
      .toList();

  Widget getBarGraph() {
    num maxAbsVal =
        _totals.values.reduce((a, b) => a.abs() > b.abs() ? a.abs() : b.abs());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _totals.entries.map((entry) {
        num relativeVal;

        if (maxAbsVal == 0) {
          relativeVal = 0;
        } else {
          relativeVal = entry.value / maxAbsVal;
        }
        num containerWidth = relativeVal.abs() * screenWidth * .4;
        bool negative = relativeVal < 0;

        return Stack(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: !negative ? Style.redFadeBoxDecoration : null,
                  width: containerWidth,
                  height: 30.0,
                  child: negative
                      ? Text(
                          '\$${entry.value.round()}',
                          textAlign: TextAlign.end,
                          style: Style.regularTextStyle,
                        )
                      : null,
                ),
                Container(
                  decoration: negative ? Style.greenFadeBoxDecoration : null,
                  width: containerWidth,
                  height: 30.0,
                  child: !negative
                      ? Text(
                          '\$${entry.value.round()}',
                          style: Style.regularTextStyle,
                        )
                      : null,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${entry.key}:',
                    style: Style.regularTextStyle,
                  ),
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  void resetTotal() => _totals = {};
}

class ListOrBarGraphSelected {}

class TotalsListSelected extends ListOrBarGraphSelected {}

class TotalsGraphSelected extends ListOrBarGraphSelected {}
