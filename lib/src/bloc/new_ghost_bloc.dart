import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/user.dart';

class NewGhostBloc implements BlocBase {
  final GroupBloc groupBloc;
  final Repository repo = Repository.getRepo;

  NewGhostBloc({this.groupBloc}) {
    assert(groupBloc != null);
    repo
        .userStream(groupBloc.groupId)
        .map((userList) => userList.where((user) => user.ghost).toList())
        .listen(_mapUsersToTiles);
  }

  BehaviorSubject<String> _newGhostNameController = BehaviorSubject<String>();
  Stream<String> get ghostName =>
      _newGhostNameController.stream.transform(_ghostTransformer);
  Function get newGhostName => _newGhostNameController.sink.add;
  bool _usernameOk = false;
  bool _submitted = false;
  String _ghostName;

  StreamController<List<Widget>> _ghostWidgetController =
      StreamController<List<Widget>>();
  Stream get ghostWidgets => _ghostWidgetController.stream;

  void _mapUsersToTiles(List<User> users) {
    List<Widget> widgetList = users
        .map((user) => ListTile(
              title: Text(user.userName),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteGhostUser(user.userId),
              ),
            ))
        .toList();
    _ghostWidgetController.sink.add(widgetList);
  }

  Future<void> submitGhost() async {
    if (_usernameOk && !_submitted) {
      _submitted = true;
      await repo.createGhostUser(groupBloc.groupId, _ghostName);
      await repo.tabulateTotals(groupBloc.groupId);
    }
    reset();
    return Future.delayed(Duration(seconds: 0));
  }

  Future<void> _deleteGhostUser(String userId) async {
    await repo.deleteGhostUser(userId, groupBloc.accountBloc.currentUser.userId, groupBloc.groupId);
    return repo.tabulateTotals(groupBloc.groupId);
  }

  void reset() {
    _usernameOk = false;
    _submitted = false;
    _ghostName = null;
  }

  StreamTransformer<String, String> get _ghostTransformer =>
      StreamTransformer.fromHandlers(
        handleData: (string, sink) {
          if (groupBloc.usersInAccount
              .where(
                  (user) => user.userName.toLowerCase() == string.toLowerCase())
              .toList()
              .isNotEmpty) {
            _usernameOk = false;
          } else {
            _usernameOk = true;
            _ghostName = string;
            sink.add(string);
          }
        },
      );

  @override
  void dispose() {
    _newGhostNameController.close();
    _ghostWidgetController.close();
  }
}
