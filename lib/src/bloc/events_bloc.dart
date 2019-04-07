import 'dart:async';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/payment.dart';

class EventsBloc implements BlocBase {

  String accountId;

  List<Payment> _thePayments;
  List<Bill> _theBills;
  List<AnyEvent> _theEvents;

  StreamController<List<AnyEvent>> _eventsListController = StreamController<List<AnyEvent>>();
  Stream<List<AnyEvent>> get eventList => _eventsListController.stream;
  Repository repo = Repository.getRepo;

  StreamSubscription _paymentsSubscription;
  StreamSubscription _billsSubscription;

  EventsBloc({this.accountId}){
    assert(accountId != null);
    _paymentsSubscription = repo.paymentStream(accountId).listen(_mapPaymentsToEvents);
    _billsSubscription = repo.billStream(accountId).listen(_mapBillsToEvents);
  }

  void _mapPaymentsToEvents(List<Payment> payments){
    _thePayments =payments;
    _setEvents();
    _eventsListController.sink.add(_theEvents);
  }
  
  void _mapBillsToEvents(List<Bill> bills){
    _theBills = bills;
    _setEvents();
    _eventsListController.sink.add(_theEvents);
  }

  void addEvent(AnyEvent event){
    if(event is Bill){
      repo.createBill(accountId, event);
    }
    if(event is Payment){
      repo.createPayment(accountId, event);
    }
  }

  void _setEvents(){
    _theEvents = List<AnyEvent>.from((_theBills ?? [])) + List<AnyEvent>.from((_thePayments ?? []));
    _theEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  void dispose() {
    _eventsListController.close();
    _paymentsSubscription.cancel();
    _billsSubscription.cancel();
  }
}
