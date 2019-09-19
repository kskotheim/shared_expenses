import 'dart:async';

import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/db_strings.dart';


class RequestsBloc implements BlocBase {
  
  final Repository _repo = Repository();
  final String accountId;
  StreamSubscription subscription;

  //returns a Stream of 2-item lists. The first item in each list is the username, the second is the userId
  StreamController<List<List<String>>> _requestsController = StreamController<List<List<String>>>();
  Stream<List<List<String>>> get requests => _requestsController.stream;

  RequestsBloc({this.accountId}){
    assert(accountId != null);
    subscription = _repo.connectionRequests(accountId).listen(_mapRequestsToNames);
  }

  void approveConnectionRequest(String userId) async {
    _repo.deleteConnectionRequest(accountId, userId);
    _repo.addUserToAccount(userId, accountId);
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
