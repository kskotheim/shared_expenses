import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/res/models/event.dart';

// This class manages the fields on the edit bill / payment page.
// It is an instance variable to editDeleteEventBloc.
// When an event is selected, values are reset, set to the event's values, and then when the widget is built (and streams listened to) the streams are initialized

// *figure out best place / how to call setEvent / loadEvent

class EditEventBloc implements BlocBase {
  final GroupBloc groupBloc;
  // AnyEvent event;

  Bill theBill;
  Payment thePayment;

  num _newAmount;
  String _newCategory;
  String _newNotes;
  String _newPaidByUser;
  DateTime _newFromDate;
  DateTime _newToDate;

  String _newFromUser;
  String _newToUser;

  Bill get updatedBill => theBill != null
      ? Bill(
          amount: _newAmount,
          type: _newCategory,
          notes: _newNotes,
          paidByUserId: _newPaidByUser,
          fromDate: _newFromDate,
          toDate: _newToDate,
          createdAt: theBill.createdAt,
          billId: theBill.billId)
      : null;

  Payment get updatedPayment => thePayment != null
      ? Payment(
          amount: _newAmount,
          fromUserId: _newFromUser,
          toUserId: _newToUser,
          notes: _newNotes,
          createdAt: thePayment?.createdAt,
          paymentId: thePayment.paymentId)
      : null;

  EditEventBloc({this.groupBloc}) : assert(groupBloc != null);

  void loadEvent() {
    if (theBill != null) {
      newAmount(_newAmount);
      updateCategory(_newCategory);
      updateNotes(_newNotes);
      updateFromDate(_newFromDate);
      updateToDate(_newToDate);
      updatePaidByUser(_newPaidByUser);
    }
    if (thePayment != null) {
      newAmount(_newAmount);
      updateFromUser(_newFromUser);
      updateToUser(_newToUser);
      updateNotes(_newNotes);
    }
  }

  void setEvent(AnyEvent event) {
    print(event);
    _reset();
    if (event is Bill) {
      _newAmount = (event.amount);
      _newCategory = (event.type);
      _newNotes = (event.notes);
      _newPaidByUser = (event.paidByUserId);
      _newFromDate = (event.fromDate);
      _newToDate = (event.toDate);
      theBill = event;
    }
    if (event is Payment) {
      _newAmount = (event.amount);
      _newFromUser = (event.fromUserId);
      _newToUser = (event.toUserId);
      _newNotes = (event.notes);
      thePayment = event;
    }
  }

  void _reset() {
    theBill = null;
    thePayment = null;
    _newAmount = null;
    _newCategory = null;
    _newNotes = null;
    _newPaidByUser = null;
    _newFromDate = null;
    _newToDate = null;
    _newFromUser = null;
    _newToUser = null;
  }

  // Stream for amount
  BehaviorSubject<num> _amountController = BehaviorSubject<num>();
  Stream<num> get amount => _amountController.stream;
  void newAmount(num amount) {
    _newAmount = amount;
    _validateUpdate();
    _amountController.sink.add(amount);
  }

  // Stream for category
  BehaviorSubject<String> _categoryController = BehaviorSubject<String>();
  Stream<String> get category => _categoryController.stream;
  void updateCategory(String category) {
    _newCategory = category;
    _validateUpdate();
    _categoryController.sink.add(category);
  }

  // Stream for notes
  BehaviorSubject<String> _notesController = BehaviorSubject<String>();
  Stream<String> get notes => _notesController.stream;
  void updateNotes(String notes) {
    _notesController.sink.add(notes);
    _newNotes = notes;
    _validateUpdate();
  }

  // Stream for user who paid the bill
  BehaviorSubject<String> _paidByUserController = BehaviorSubject<String>();
  Stream<String> get paidByUser => _paidByUserController.stream;
  void updatePaidByUser(String user) {
    _newPaidByUser = user;
    _validateUpdate();
    _paidByUserController.sink.add(user);
  }

  //Stream for from date
  BehaviorSubject<DateTime> _fromDateController = BehaviorSubject<DateTime>();
  Stream<DateTime> get fromDate => _fromDateController.stream;
  void updateFromDate(DateTime fromDate) {
    _fromDateController.sink.add(fromDate);
    _newFromDate = fromDate;
    _validateUpdate();
  }

  //Stream for to date
  BehaviorSubject<DateTime> _toDateController = BehaviorSubject<DateTime>();
  Stream<DateTime> get toDate => _toDateController.stream;
  void updateToDate(DateTime toDate) {
    _newToDate = toDate;
    _validateUpdate();
    _toDateController.sink.add(toDate);
  }

  //Stream for payment 'from user'
  BehaviorSubject<String> _fromUserController = BehaviorSubject<String>();
  Stream<String> get fromUser => _fromUserController.stream;
  void updateFromUser(String user) {
    _newFromUser = user;
    _validateUpdate();
    _fromUserController.sink.add(user);
  }

  //Stream for payment 'to user'
  BehaviorSubject<String> _toUserController = BehaviorSubject<String>();
  Stream<String> get toUser => _toUserController.stream;
  void updateToUser(String toUser) {
    _newToUser = toUser;
    _validateUpdate();
    _toUserController.sink.add(toUser);
  }

  //Stream for validating the updated values
  BehaviorSubject<bool> _updateValidController = BehaviorSubject<bool>();
  Stream<bool> get updateValid => _updateValidController.stream;
  void _validateUpdate() {
    if (theBill != null) {
      bool amtChanged = _newAmount != theBill.amount;
      bool paidByChanged = _newPaidByUser != theBill.paidByUserId;
      bool fromChanged = !_newFromDate.isAtSameMomentAs(theBill.fromDate);
      bool toChanged = !_newToDate.isAtSameMomentAs(theBill.toDate);
      bool catChanged = _newCategory != theBill.type;
      bool notesChanged = _newNotes != theBill.notes;
      if (amtChanged ||
          paidByChanged ||
          fromChanged ||
          toChanged ||
          notesChanged ||
          catChanged) {
        if (_newFromDate.isBefore(_newToDate) ||
            _newFromDate.isAtSameMomentAs(_newToDate)) if (_newAmount >= 0)
          return _updateValidController.sink.add(true);
      }
    }
    if (thePayment != null) {
      bool amtChanged = _newAmount != thePayment.amount;
      bool fromChanged = _newFromUser != thePayment.fromUserId;
      bool toChanged = _newToUser != thePayment.toUserId;
      bool notesChanged = _newNotes != thePayment.notes;
      if (amtChanged || fromChanged || toChanged || notesChanged) {
        if (_newAmount > 0) if (_newFromUser != _newToUser)
          return _updateValidController.sink.add(true);
      }
    }
    _updateValidController.sink.add(false);
  }

  void dispose() {
    _amountController.close();
    _categoryController.close();
    _notesController.close();
    _paidByUserController.close();
    _fromUserController.close();
    _toUserController.close();
    _fromDateController.close();
    _toDateController.close();
    _updateValidController.close();
  }
}
