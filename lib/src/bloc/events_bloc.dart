import 'dart:async';
import 'package:shared_expenses/src/bloc/account_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/payment.dart';

class EventsBloc implements BlocBase {

  AccountBloc accountBloc;
  String _accountId;

  List<Payment> _thePayments;
  List<Bill> _theBills;
  List<AnyEvent> _theEvents;
  List<String> _theEventNames;

  StreamController<List<String>> _eventsListController = StreamController<List<String>>();
  Stream<List<String>> get eventList => _eventsListController.stream;
  Repository repo = Repository.getRepo;

  StreamSubscription _paymentsSubscription;
  StreamSubscription _billsSubscription;

  EventsBloc({this.accountBloc}){
    assert(accountBloc != null);
    _accountId = accountBloc.currentAccount.accountId;
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
        return '${accountBloc.userName(event.fromUserId)} paid ${accountBloc.userName(event.toUserId)} \$${event.amount.floor()}';
      }
      if(event is Bill){
        return '${accountBloc.userName(event.paidByUserId)} paid \$${event.amount.floor()} ${event.type} bill';
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
