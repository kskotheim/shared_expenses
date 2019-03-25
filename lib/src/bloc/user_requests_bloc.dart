import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/db_strings.dart';

class UserRequestsBloc implements BlocBase {
  final String userId;
  final Repository repo =Repository();

  StreamSubscription _subscription;

  StreamController<List<String>> _requestsController = StreamController<List<String>>();
  Stream<List<String>> get requests => _requestsController.stream;

  UserRequestsBloc({this.userId}){
    assert(userId != null);
    _subscription = repo.currentUserStream(userId).listen(_mapDocumentToUserRequestList);
  }

  void _mapDocumentToUserRequestList(DocumentSnapshot doc) async {
    if(doc.data == null || doc.data[CONNECTION_REQUESTS] == null || doc.data[CONNECTION_REQUESTS].length == 0) return;

    List<String> requestedAccountNames = await repo.getAccountNamesList(List<String>.from(doc.data[CONNECTION_REQUESTS]));

    _requestsController.sink.add(requestedAccountNames);
  }

  @override
  void dispose() {
    _requestsController.close();
    _subscription.cancel();
  }
}