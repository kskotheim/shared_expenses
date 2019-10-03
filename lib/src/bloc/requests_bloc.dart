import 'dart:async';

import 'package:rxdart/subjects.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/db_strings.dart';
import 'package:shared_expenses/src/res/models/event.dart';


class RequestsBloc implements BlocBase {
  
  final Repository _repo = Repository();
  final String accountId;
  StreamSubscription subscription;

  //returns a Stream of 2-item lists. The first item in each list is the username, the second is the userId
  BehaviorSubject<List<List<String>>> _requestsController = BehaviorSubject<List<List<String>>>();
  Stream<List<List<String>>> get requests => _requestsController.stream;

  RequestsBloc({this.accountId}){
    assert(accountId != null);
    subscription = _repo.connectionRequests(accountId).listen(_mapRequestsToNames);
  }

  void approveConnectionRequest(String userId) async {

    // this should be done by the user, not the administrator? or anyone can modify user document ...
    _repo.deleteConnectionRequest(accountId, userId);
    _repo.addUserToAccount(userId, accountId);
    _repo.createAccountEvent(accountId, AccountEvent(userId: userId, actionTaken: 'added to account'));
  }
  
  void deleteConnectionRequest(String userId) async {
    _repo.deleteConnectionRequest(accountId, userId);
  }
  
  void _mapRequestsToNames(List<Map<String, dynamic>> users) async {
    List<List<String>> names = users.map((user){
        return List<String>.from([user[NAME], user[ID]]);
    }).toList();
    _requestsController.sink.add(names);
  }
  
  
  @override
  void dispose() {
    _requestsController.close();
    subscription.cancel();
  }
}
