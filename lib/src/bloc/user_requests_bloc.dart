import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/user.dart';

class UserRequestsBloc implements BlocBase {
  final String userId;
  final Repository repo =Repository();

  StreamSubscription<User> _subscription;

  BehaviorSubject<List<String>> _requestsController = BehaviorSubject<List<String>>();
  Stream<List<String>> get requests => _requestsController.stream;

  UserRequestsBloc({this.userId}){
    assert(userId != null);
    _subscription = repo.currentUserStream(userId).listen(_mapDocumentToUserRequestList);
  }

  void _mapDocumentToUserRequestList(User user) async {
    if(user.connectionRequests.length == 0) return;

    List<String> requestedAccountNames = await repo.getGroupNamesList(List<String>.from(user.connectionRequests));

    _requestsController.sink.add(requestedAccountNames);
  }

  @override
  void dispose() {
    _requestsController.close();
    _subscription.cancel();
  }
}