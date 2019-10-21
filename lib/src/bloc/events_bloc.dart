import 'dart:async';
import 'package:flutter/material.dart';
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

  BehaviorSubject<List<List<Text>>> _eventsListController =BehaviorSubject<List<List<Text>>>();
  Stream<List<List<Text>>> get eventList => _eventsListController.stream;
  Repository repo = Repository.getRepo;

  BehaviorSubject<EventSortMethod> _eventSortMethodController =BehaviorSubject<EventSortMethod>();
  Stream<EventSortMethod> get eventSortMethod =>_eventSortMethodController.stream;
  void sortByAll() => _eventSortMethodController.sink.add(SortAll());
  void sortByBill() => _eventSortMethodController.sink.add(SortBills());
  void sortByPayment() => _eventSortMethodController.sink.add(SortPayments());
  void sortByAccountEvents() =>_eventSortMethodController.sink.add(SortAccountEvents());
  EventSortMethod _theSortMethod;

  StreamSubscription _paymentsSubscription;
  StreamSubscription _billsSubscription;
  StreamSubscription _accountEventsSubscription;
  StreamSubscription _usersSubscription;

  EventsBloc({this.groupBloc}) {
    assert(groupBloc != null);
    _accountId = groupBloc.accountId;
    _paymentsSubscription = repo.paymentStream(_accountId).listen(_mapPaymentsToEvents);
    _billsSubscription = repo.billStream(_accountId).listen(_mapBillsToEvents);
    _accountEventsSubscription = repo.accountEventStream(_accountId).listen(_mapAccountEventToEvent);
    _eventSortMethodController.stream.listen((method) {
      _theSortMethod = method;
      _setEvents();
    });
    _usersSubscription = groupBloc.usersInAccountStream.listen((users) => _setEvents());
    sortByAll();
  }

  void _mapPaymentsToEvents(List<Payment> payments) {
    _thePayments = payments;
    _setEvents();
  }

  void _mapBillsToEvents(List<Bill> bills) {
    _theBills = bills;
    _setEvents();
  }

  void _mapAccountEventToEvent(List<AccountEvent> accountEvents) {
    _theAccountEvents = accountEvents;
    _setEvents();
  }

  void _setEvents() {
    List<AnyEvent> _allEvents;

    if (_theSortMethod is SortAll) {
      _allEvents = _clarifyEventList(_theBills) +
          _clarifyEventList(_thePayments) +
          _clarifyEventList(_theAccountEvents);
    }
    if (_theSortMethod is SortBills) {
      _allEvents = _clarifyEventList(_theBills);
    }
    if (_theSortMethod is SortPayments) {
      _allEvents = _clarifyEventList(_thePayments);
    }
    if (_theSortMethod is SortAccountEvents) {
      _allEvents = _clarifyEventList(_theAccountEvents);
    }
 
    _allEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    List<List<Text>> theEventTextWidgets = List<List<Text>>.from(_allEvents.map((event) {
      String primaryString;
      String secondaryString;
      TextStyle textStyle;

      if (event is Payment) {
        primaryString = '${groupBloc.userName(event.fromUserId)} paid ${groupBloc.userName(event.toUserId)} \$${event.amount.floor()}';
        textStyle =  TextStyle(color: Colors.green.shade600);
        secondaryString = 'Made on ${event.createdAt.month}/${event.createdAt.day}';
        if(event.notes != null && event.notes.length > 0) secondaryString += ', ${event.notes}';
      }
      if (event is Bill) {
        primaryString =  '${groupBloc.userName(event.paidByUserId)} paid \$${event.amount.floor()} ${event.type} bill';
        textStyle =  TextStyle(color: Colors.red.shade600);
        secondaryString = 'Paid on ${event.createdAt.month}/${event.createdAt.day}';
        if(event.fromDate == null || !event.fromDate.isAtSameMomentAs(event.createdAt)) secondaryString += ', from ${event.fromDate.month}/${event.fromDate.day} to ${event.toDate.month}/${event.toDate.day}';
      }
      if (event is AccountEvent) {
        primaryString = '${groupBloc.userName(event.userId)} ${event.actionTaken}';
        textStyle =  TextStyle(color: Colors.blue);
        secondaryString = 'Event occured on ${event.createdAt.month}/${event.createdAt.day}';
      }

      return <Text>[Text(primaryString, style: textStyle,), Text(secondaryString)];
    }));

    _eventsListController.sink.add(theEventTextWidgets);
  }

  List<AnyEvent> _clarifyEventList(List<AnyEvent> list) {
    return List<AnyEvent>.from(list ?? []);
  }

  @override
  void dispose() {
    _eventsListController.close();
    _paymentsSubscription.cancel();
    _billsSubscription.cancel();
    _accountEventsSubscription.cancel();
    _eventSortMethodController.close();
    _usersSubscription.cancel();
  }
}

class EventSortMethod {}

class SortAll extends EventSortMethod {}

class SortBills extends EventSortMethod {}

class SortPayments extends EventSortMethod {}

class SortAccountEvents extends EventSortMethod {}
