import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/event.dart';
import 'package:shared_expenses/src/res/util.dart';

class NewEventBloc implements BlocBase {
  final Repository _repo = Repository.getRepo;
  final GroupBloc groupBloc;

  BillOrPaymentSection _selectedOption;
  String _selectedUser;
  String _paymentNotes;
  String _billNotes;
  double _billAmount;
  String _billType;
  DateTime _fromDate;
  DateTime _toDate;

  bool _submitted = false;

  void _resetVals() {
    _selectedUser = null;
    _paymentNotes = null;
    _billNotes = null;
    _billAmount = null;
    _billType = null;
    _fromDate = null;
    _toDate = null;
  }

  // Whether to show bill or payment section
  BehaviorSubject<BillOrPaymentSection> _selectedOptionController =
      BehaviorSubject<BillOrPaymentSection>();
  Stream<BillOrPaymentSection> get selectedOption =>
      _selectedOptionController.stream.map(_saveSelectedOption);
  void showBillSection() =>
      _selectedOptionController.sink.add(ShowBillSection());
  void showPaymentSection() =>
      _selectedOptionController.sink.add(ShowPaymentSection());
  BillOrPaymentSection _saveSelectedOption(BillOrPaymentSection section) {
    _resetVals();
    _selectedOption = section;
    return section;
  }

  // Whether to show confirm dialog
  StreamController<bool> _showConfirmationController = StreamController<bool>();
  Stream<bool> get showConfirmationStream => _showConfirmationController.stream;
  void showConfirmation() => _showConfirmationController.sink.add(true);
  void hideConfirmation() => _showConfirmationController.sink.add(false);

  //Payment options:
  //User payment is to
  BehaviorSubject<String> _selectedUserController = BehaviorSubject<String>();
  Stream<String> get selectedUser =>
      _selectedUserController.stream.map(_saveUser);
  Function get selectUser => _selectedUserController.sink.add;
  String get selectedUserName => groupBloc.usersInAccount.firstWhere((user) => user.userId == _selectedUser).userName;

  String _saveUser(String user) {
    _selectedUser = user;
    _checkIfPaymentPageIsValid();
    return user;
  }

  //Amount
  BehaviorSubject<double> _billAmountController = BehaviorSubject<double>();
  Stream<double> get billAmount =>
      _billAmountController.stream.map(_saveAmount);
  void newBillAmount(String amt) =>
      _billAmountController.sink.add(double.parse(amt));

  double _saveAmount(double amount) {
    _billAmount = amount;
    _checkIfPaymentPageIsValid();
    _checkIfBillPageIsValid();
    return amount;
  }

  //Notes
  BehaviorSubject<String> _paymentNotesController = BehaviorSubject<String>();
  Stream<String> get paymentNotes =>
      _paymentNotesController.stream.map(_saveNotes);
  Function get newPaymentNote => _paymentNotesController.sink.add;

  String _saveNotes(String notes) {
    _paymentNotes = notes;
    return notes;
  }
  BehaviorSubject<String> _billNotesController = BehaviorSubject<String>();
  Stream<String> get billNotes =>
      _billNotesController.stream.map(_saveBillNotes);
  Function get newBillNote => _billNotesController.sink.add;

  String _saveBillNotes(String notes) {
    _billNotes = notes;
    return notes;
  }
  //Bill options:
  //Bill type


  BehaviorSubject<String> _selectedTypeController = BehaviorSubject<String>();
  Stream<String> get selectedType =>
      _selectedUserController.stream.map(_saveType);
  Function get selectType => _selectedUserController.sink.add;

  String _saveType(String type) {
    _billType = type;
    _checkIfBillPageIsValid();
    return type;
  }

  //Amount
  //Same controller as above

  //Bill from date
  BehaviorSubject<DateTime> _fromDateController = BehaviorSubject<DateTime>();
  Stream<DateTime> get fromDate =>
      _fromDateController.stream.map(_saveFromDate);
  Function get newFromDate => _fromDateController.sink.add;

  DateTime _saveFromDate(DateTime fromDate) {
    _fromDate = fromDate;
    return fromDate;
  }

  //Bill to date
  BehaviorSubject<DateTime> _toDateControlelr = BehaviorSubject<DateTime>();
  Stream<DateTime> get toDate => _toDateControlelr.stream.map(_saveToDate);
  Function get newToDate => _toDateControlelr.sink.add;

  DateTime _saveToDate(DateTime toDate) {
    _toDate = toDate;
    return toDate;
  }

  NewEventBloc({this.groupBloc}) {
    assert(groupBloc != null);
  }

  // payment and bill page validators
  BehaviorSubject<bool> _paymentPageValidator = BehaviorSubject<bool>();
  Stream get paymentPageValidated => _paymentPageValidator.stream;

  BehaviorSubject<bool> _billPageValidator = BehaviorSubject<bool>();
  Stream get billPageValidated => _billPageValidator.stream;

  void _checkIfPaymentPageIsValid() {
    if (_selectedUser != null && _billAmount != null)
      _paymentPageValidator.sink.add(true);
  }
void _checkIfBillPageIsValid() {
    if (_billType != null && _billAmount != null)
      _billPageValidator.sink.add(true);
  }

  Future<void> submitInfo() {
    if (!_submitted) {
      _submitted = true;
      if (_selectedOption is ShowBillSection) {
        if (_billAmount != null && _billType != null) {
          return _repo
              .createBill(
                  groupBloc.accountId,
                  Bill(
                      amount: _billAmount,
                      paidByUserId: groupBloc.userId,
                      type: _billType,
                      notes: _billNotes,
                      createdAt: DateTime.now(),
                      fromDate: _fromDate,
                      toDate: _toDate))
              .then((_) => _repo.tabulateTotals(
                  groupBloc.accountId, groupBloc.usersInAccount));
        } else
          return Future.delayed(Duration(seconds: 0));
      } else if (_selectedOption is ShowPaymentSection) {
        if (_selectedUser != null && _billAmount != null) {
          return _repo
              .createPayment(
                  groupBloc.accountId,
                  Payment(
                      fromUserId: groupBloc.userId,
                      toUserId: _selectedUser,
                      amount: _billAmount,
                      notes: _paymentNotes,
                      createdAt: DateTime.now()))
              .then((_) => _repo.tabulateTotals(
                  groupBloc.accountId, groupBloc.usersInAccount));
        } 
      } 
    }
    return Future.delayed(Duration(seconds: 0));
  }

  List<Widget> selectedEventDetails(){
    if(_selectedOption is ShowBillSection){
      return <Widget>[
        Text('Bill'),
        Text('Amount: \$${_billAmount.toStringAsFixed(2)}' ),
        Text('Type: $_billType'),
        Text('From: ${parseDateTime(_fromDate) ?? 'Current'}'),
        Text('To: ${parseDateTime(_toDate) ?? 'Current'}'),
      ];
    } else {
      return <Widget>[
        Text('Payment'),
        Text('Amount: \$${_billAmount.toStringAsFixed(2)}' ),
        Text('To: ${groupBloc.userName(_selectedUser)}'),
      ];
    }
  }

  @override
  void dispose() {
    _selectedUserController.close();
    _selectedOptionController.close();
    _billAmountController.close();
    _paymentNotesController.close();
    _toDateControlelr.close();
    _fromDateController.close();
    _paymentPageValidator.close();
    _selectedTypeController.close();
    _billPageValidator.close();
    _billNotesController.close();
    _showConfirmationController.close();
  }
}

class BillOrPaymentSection {}

class ShowBillSection extends BillOrPaymentSection {}

class ShowPaymentSection extends BillOrPaymentSection {}

