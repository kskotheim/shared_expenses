import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/event.dart';

class EventsBloc implements BlocBase {

  GroupBloc groupBloc;
  String _accountId;

  List<Payment> _thePayments;
  List<Bill> _theBills;
  List<AccountEvent> _theAccountEvents;
  List<AnyEvent> _allEvents;
  List<String> _theEventNames;

  BehaviorSubject<List<String>> _eventsListController = BehaviorSubject<List<String>>();
  Stream<List<String>> get eventList => _eventsListController.stream;
  Repository repo = Repository.getRepo;

  StreamSubscription _paymentsSubscription;
  StreamSubscription _billsSubscription;
  StreamSubscription _accountEventsSubscription;

  EventsBloc({this.groupBloc}){
    assert(groupBloc != null);
    _accountId = groupBloc.accountId;
    _paymentsSubscription = repo.paymentStream(_accountId).listen(_mapPaymentsToEvents);
    _billsSubscription = repo.billStream(_accountId).listen(_mapBillsToEvents);
    _accountEventsSubscription = repo.accountEventStream(_accountId).listen(_mapAccountEventToEvent);
  }

  void _mapPaymentsToEvents(List<Payment> payments){
    _thePayments =payments;
    _setEvents();
  }
  
  void _mapBillsToEvents(List<Bill> bills){
    _theBills = bills;
    _setEvents();
  }

  void _mapAccountEventToEvent(List<AccountEvent> accountEvents){
    _theAccountEvents = accountEvents;
    _setEvents();
  }

  void _setEvents(){
    _allEvents = _clarifyEventList(_theBills) + _clarifyEventList(_thePayments) + _clarifyEventList(_theAccountEvents);
    _allEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _theEventNames = _allEvents.map((event){
      if(event is Payment){
        return '${groupBloc.userName(event.fromUserId)} paid ${groupBloc.userName(event.toUserId)} \$${event.amount.floor()}';
      }
      if(event is Bill){
        return '${groupBloc.userName(event.paidByUserId)} paid \$${event.amount.floor()} ${event.type} bill';
      }
      if(event is AccountEvent){
        return '${groupBloc.userName(event.userId)} ${event.actionTaken}';
      }
      return 'error';
    }).toList();

    _eventsListController.sink.add(_theEventNames);
  }

  List<AnyEvent> _clarifyEventList(List<AnyEvent> list){
    return List<AnyEvent>.from(list ?? []);
  }

  @override
  void dispose() {
    _eventsListController.close();
    _paymentsSubscription.cancel();
    _billsSubscription.cancel();
    _accountEventsSubscription.cancel();
  }

}
