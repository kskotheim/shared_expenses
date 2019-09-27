import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/payment.dart';

class EventsBloc implements BlocBase {

  GroupBloc groupBloc;
  String _accountId;

  List<Payment> _thePayments;
  List<Bill> _theBills;
  List<AnyEvent> _theEvents;
  List<String> _theEventNames;

  BehaviorSubject<List<String>> _eventsListController = BehaviorSubject<List<String>>();
  Stream<List<String>> get eventList => _eventsListController.stream;
  Repository repo = Repository.getRepo;

  StreamSubscription _paymentsSubscription;
  StreamSubscription _billsSubscription;

  EventsBloc({this.groupBloc}){
    assert(groupBloc != null);
    _accountId = groupBloc.accountId;
    _paymentsSubscription = repo.paymentStream(_accountId).listen(_mapPaymentsToEvents);
    _billsSubscription = repo.billStream(_accountId).listen(_mapBillsToEvents);
  }

  void _mapPaymentsToEvents(List<Payment> payments){
    _thePayments =payments;
    _setEvents();
    _eventsListController.sink.add(_theEventNames);
  }
  
  void _mapBillsToEvents(List<Bill> bills){
    _theBills = bills;
    _setEvents();
    _eventsListController.sink.add(_theEventNames);
  }

  void _setEvents(){
    _theEvents = List<AnyEvent>.from((_theBills ?? [])) + List<AnyEvent>.from((_thePayments ?? []));
    _theEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _theEventNames = _theEvents.map((event){
      if(event is Payment){
        return '${groupBloc.userName(event.fromUserId)} paid ${groupBloc.userName(event.toUserId)} \$${event.amount.floor()}';
      }
      if(event is Bill){
        return '${groupBloc.userName(event.paidByUserId)} paid \$${event.amount.floor()} ${event.type} bill';
      }
      return 'error';
    }).toList();
  }

  @override
  void dispose() {
    _eventsListController.close();
    _paymentsSubscription.cancel();
    _billsSubscription.cancel();
  }

}
