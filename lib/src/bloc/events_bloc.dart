import 'dart:async';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/payment.dart';

class EventsBloc implements BlocBase {

  String accountId;

  StreamController<List<AnyEvent>> _eventsListController = StreamController<List<AnyEvent>>();
  Stream<List<AnyEvent>> get eventList => _eventsListController.stream;
  Repository repo = Repository.getRepo;

  StreamSubscription _eventsSubscription;

  EventsBloc({this.accountId}){
    assert(accountId != null);
    _eventsSubscription = repo.paymentStream(accountId).listen(_mapPaymentsToEvents);
  }

  void _mapPaymentsToEvents(List<Map<String, dynamic>> payments){
    _eventsListController.sink.add(payments.map((doc) => Payment.fromJson(doc)).toList());
  }

  void addEvent(String name){

    Map<String, dynamic> newEvent = {
      'fromUserId':'Kris',
      'toUserId':'Dre',
      'amount':5.0,
    };

    repo.createPayment(accountId, newEvent);
  }

  @override
  void dispose() {
    _eventsListController.close();
    _eventsSubscription.cancel();
  }
}
