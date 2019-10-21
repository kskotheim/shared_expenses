

import 'dart:async';

import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/user.dart';

class UserModifierBloc implements BlocBase {

  final GroupBloc groupBloc;
  final Repository repo = Repository.getRepo;

  StreamController<List<UserModifier>> _userModifierListController = StreamController<List<UserModifier>>();
  Stream<List<UserModifier>> get userModifierStream => _userModifierListController.stream;
  

  


  UserModifierBloc({this.groupBloc}){
    assert(groupBloc != null);
    repo.userModifierStream(groupBloc.accountId).listen(_userModifierListController.sink.add);
    

  }



  @override
  void dispose() {
    _userModifierListController.close();
  
  }



}