import 'dart:async';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/payment.dart';

class EventsBloc implements BlocBase {

  StreamController<List<AnyEvent>> _eventsListController = StreamController<List<AnyEvent>>();
  Stream<List<AnyEvent>> get eventList => _eventsListController.stream;
  Repository repo = Repository();

  //dummy data
  List<AnyEvent> _data = [];

  EventsBloc(){
    _getData();
  }

  void _getData() async {
    _data = await repo.getEvents();
    _eventsListController.sink.add(_data);
  }

  void addEvent(String name){

    Map<String, dynamic> newEvent = {
      'fromUserId':'Kris',
      'toUserId':'Dre',
      'amount':5.0,
    };

    repo.createPayment(newEvent).then((_) => _getData());
  }

  @override
  void dispose() {
    _eventsListController.close();
  }
}
