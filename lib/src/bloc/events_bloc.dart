import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/event.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/res/util.dart';

// This class broadcasts the list of events to the events list widget and tracks how the user wants the events to be displayed / sorted

class EventsBloc implements BlocBase {
  GroupBloc groupBloc;
  String _accountId;

  List<Payment> _thePayments;
  List<Bill> _theBills;
  List<AccountEvent> _theAccountEvents;

  BehaviorSubject<List<List<Widget>>> _eventsListController =
      BehaviorSubject<List<List<Widget>>>();
  Stream<List<List<Widget>>> get eventList => _eventsListController.stream;
  Repository repo = Repository.getRepo;

  BehaviorSubject<EventSortMethod> _eventSortMethodController =
      BehaviorSubject<EventSortMethod>();
  Stream<EventSortMethod> get eventSortMethod =>
      _eventSortMethodController.stream;
  void sortByAll() => _eventSortMethodController.sink.add(EventSortMethod());
  void sortByBill() => _eventSortMethodController.sink
      .add(EventSortMethod(sortList: [true, false, false]));
  void sortByPayment() => _eventSortMethodController.sink
      .add(EventSortMethod(sortList: [false, true, false]));
  void sortByAccountEvents() => _eventSortMethodController.sink
      .add(EventSortMethod(sortList: [false, false, true]));

  void addSortByBill() {
    if (_theSortMethod.indexIsOnlyTrue(0)) {
      sortByAll();
    } else {
      _theSortMethod[0] = !_theSortMethod[0];
      _eventSortMethodController.sink.add(_theSortMethod);
    }
  }

  void addSortByPayment() {
    if (_theSortMethod.indexIsOnlyTrue(1)) {
      sortByAll();
    } else {
      _theSortMethod[1] = !_theSortMethod[1];
      _eventSortMethodController.sink.add(_theSortMethod);
    }
  }

  void addSortByEvent() {
    if (_theSortMethod.indexIsOnlyTrue(2)) {
      sortByAll();
    } else {
      _theSortMethod[2] = !_theSortMethod[2];
      _eventSortMethodController.sink.add(_theSortMethod);
    }
  }

  void removeSortByBill() {}

  EventSortMethod _theSortMethod;

  StreamSubscription _paymentsSubscription;
  StreamSubscription _billsSubscription;
  StreamSubscription _accountEventsSubscription;
  StreamSubscription _usersSubscription;

  EventsBloc({this.groupBloc}) {
    assert(groupBloc != null);
    _accountId = groupBloc.groupId;
    _paymentsSubscription =
        repo.paymentStream(_accountId).listen(_mapPaymentsToEvents);
    _billsSubscription = repo.billStream(_accountId).listen(_mapBillsToEvents);
    _accountEventsSubscription =
        repo.accountEventStream(_accountId).listen(_mapAccountEventToEvent);
    _eventSortMethodController.stream.listen((method) {
      _theSortMethod = method;
      _setEvents();
    });
    _usersSubscription =
        groupBloc.usersInAccountStream.listen((users) => _setEvents());
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
    List<AnyEvent> _allEvents = <AnyEvent>[];

    if (_theSortMethod.sortList[0]) {
      _allEvents += _clarifyEventList(_theBills);
    }
    if (_theSortMethod.sortList[1]) {
      _allEvents += _clarifyEventList(_thePayments);
    }
    if (_theSortMethod.sortList[2]) {
      _allEvents += _clarifyEventList(_theAccountEvents);
    }

    _allEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    List<List<Widget>> theEventTextWidgets =
        List<List<Widget>>.from(_allEvents.map((event) {
      String primaryString;
      String secondaryString;
      TextStyle textStyle;
      Widget leadingWidget = DateIcon(event.createdAt.month,
          event.createdAt.day, Colors.grey.shade200, null);

      if (event is Payment) {
        primaryString =
            '${groupBloc.userName(event.fromUserId)} paid ${groupBloc.userName(event.toUserId)} \$${event.amount.floor()}';
        textStyle = Style.regularTextStyleGreen;
        secondaryString =
            'Made on ${event.createdAt.month}/${event.createdAt.day}';
        if (event.notes != null && event.notes.length > 0)
          secondaryString += ', ${event.notes}';
      }
      if (event is Bill) {
        primaryString =
            '${groupBloc.userName(event.paidByUserId)} paid \$${event.amount.floor()} ${event.type} bill';
        textStyle = Style.regularTextStyleRed;
        secondaryString =
            'Paid on ${event.createdAt.month}/${event.createdAt.day}, ${event.notes}';
        if (event.fromDate == null ||
            !event.fromDate.isAtSameMomentAs(event.createdAt))
          secondaryString +=
              ', from ${event.fromDate.month}/${event.fromDate.day} to ${event.toDate.month}/${event.toDate.day}';
      }
      if (event is AccountEvent) {
        primaryString =
            '${groupBloc.userName(event.userId)} ${event.actionTaken}';
        textStyle = Style.regularTextStyleBlue;
        secondaryString = event.secondaryString != null
            ? event.secondaryString
            : 'Event occured on ${event.createdAt.month}/${event.createdAt.day}';
      }

      return <Widget>[
        Text(
          primaryString,
          style: textStyle,
        ),
        Text(secondaryString),
        leadingWidget
      ];
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

class EventSortMethod {
  List<bool> sortList;
  EventSortMethod({this.sortList}) {
    if (sortList == null) sortList = <bool>[true, true, true];
  }

  bool indexIsOnlyTrue(int index) {
    bool returnVal = true;
    for (int i = 0; i < 3; i++) {
      if (i != index && sortList[i]) {
        returnVal = false;
      }
    }
    if (!sortList[index]) {
      returnVal = false;
    }
    return returnVal;
  }

  operator [](int index) {
    if (index >= 0 && index <= 2)
      return sortList[index];
    else
      throw RangeError('range must be 0 to 2');
  }

  operator []=(int index, bool val) {
    if (index >= 0 && index <= 2)
      sortList[index] = val;
    else
      throw RangeError('range must be 0 to 2');
  }
}
