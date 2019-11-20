import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/event.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/res/util.dart';

class NewEventBloc implements BlocBase {
  final Repository _repo = Repository.getRepo;
  final GroupBloc groupBloc;

  BillOrPaymentSection _selectedOption;
  String _selectedUser;
  String _adminSelectedUser;
  String _paymentNotes;
  String _billNotes;
  double _billAmount;
  String _billType;
  DateTime _fromDate;
  DateTime _toDate;

  bool _submitted = false;

  NewEventBloc({this.groupBloc}) : assert(groupBloc != null);


  void _resetVals() {
    _selectedUser = null;
    _adminSelectedUser = groupBloc.userId;
    _paymentNotes = null;
    _billNotes = null;
    _billAmount = null;
    _billType = null;
    _fromDate = null;
    _toDate = null;
  }

  // Whether to show bill or payment section
  PublishSubject<BillOrPaymentSection> _selectedOptionController =
      PublishSubject<BillOrPaymentSection>();
  Stream<BillOrPaymentSection> get selectedOption =>
      _selectedOptionController.stream;

  void showBillSection() {
    _resetVals();
    _selectedOption = ShowBillSection();
    _selectedOptionController.sink.add(_selectedOption);
  }

  void showPaymentSection() {
    _resetVals();
    _selectedOption = ShowPaymentSection();
    _selectedOptionController.sink.add(_selectedOption);
  }

  // Whether the admin is modifying the user the event is from
  // This stream either contains nothing, or a single one-way event will make it contain true
  PublishSubject<bool> _adminModifyingFromUser = PublishSubject<bool>();
  Stream<bool> get adminModifyingFromUser => _adminModifyingFromUser.stream;

  void modifyFromUser() {
    adminSelectUser(groupBloc.userId);
    _adminModifyingFromUser.sink.add(true);
  }

  // Whether to show confirm dialog
  StreamController<bool> _showConfirmationController = StreamController<bool>();
  Stream<bool> get showConfirmationStream => _showConfirmationController.stream;
  void showConfirmation() => _showConfirmationController.sink.add(true);
  void hideConfirmation() => _showConfirmationController.sink.add(false);

  //Payment options:
  //User payment is to
  PublishSubject<String> _selectedUserController = PublishSubject<String>();
  Stream<String> get selectedUser => _selectedUserController.stream;

  void selectUser(String user) {
    _selectedUser = user;
    _checkIfPaymentPageIsValid();
    _selectedUserController.sink.add(user);
  }

  String get selectedUserName => groupBloc.usersInAccount
      .firstWhere((user) => user.userId == _selectedUser)
      .userName;

  //User payment is from / bill paid by
  PublishSubject<String> _adminSelectedUserController =
      PublishSubject<String>();
  Stream<String> get adminSelectedUser => _adminSelectedUserController.stream;

  void adminSelectUser(String user) {
    _adminSelectedUser = user;
    _checkIfBillPageIsValid();
    _adminSelectedUserController.sink.add(user);
  }

  String get adminSelectedUserName => groupBloc.usersInAccount
      .firstWhere((user) => user.userId == _adminSelectedUser)
      .userName;

  //Amount
  PublishSubject<double> _billAmountController = PublishSubject<double>();
  Stream<double> get billAmount => _billAmountController.stream;

  void newBillAmount(String amount) {
    _billAmount = double.tryParse(amount) ?? 0;
    _checkIfPaymentPageIsValid();
    _checkIfBillPageIsValid();
    _billAmountController.sink.add(_billAmount);
  }

  //Notes
  PublishSubject<String> _paymentNotesController = PublishSubject<String>();
  Stream<String> get paymentNotes => _paymentNotesController.stream;
  void newPaymentNote(String note) {
    _paymentNotes = note;
    _paymentNotesController.sink.add(note);
  }

  PublishSubject<String> _billNotesController = PublishSubject<String>();
  Stream<String> get billNotes => _billNotesController.stream;
  void newBillNote(String note) {
    _billNotes = note;
    _billNotesController.sink.add(note);
  }

  //Bill options:
  //Bill type

  PublishSubject<String> _selectedTypeController = PublishSubject<String>();
  Stream<String> get selectedType => _selectedUserController.stream;
  void selectType(String type) {
    _billType = type;
    _checkIfBillPageIsValid();
    _selectedUserController.sink.add(type);
  }

  //Amount
  //Same controller as above

  //Bill from date
  PublishSubject<DateTime> _fromDateController = PublishSubject<DateTime>();
  Stream<DateTime> get fromDate => _fromDateController.stream;
  void newFromDate(DateTime date) {
    _fromDate = date;
    _checkIfBillPageIsValid();
    _fromDateController.sink.add(date);
  }

  //Bill to date
  PublishSubject<DateTime> _toDateControlelr = PublishSubject<DateTime>();
  Stream<DateTime> get toDate => _toDateControlelr.stream;
  void newToDate(DateTime date) {
    _toDate = date;
    _checkIfBillPageIsValid();
    _toDateControlelr.sink.add(date);
  }

  // payment and bill page validators
  PublishSubject<bool> _paymentPageValidator = PublishSubject<bool>();
  Stream get paymentPageValidated => _paymentPageValidator.stream;

  PublishSubject<bool> _billPageValidator = PublishSubject<bool>();
  Stream get billPageValidated => _billPageValidator.stream;

  void _checkIfPaymentPageIsValid() {
    if (_selectedUser != null && _billAmount != null && _billAmount > 0)
    // make sure the user the payment is from and to are different
    if ((!groupBloc.isGroupOwner && _selectedUser != groupBloc.userId) ||
        _adminSelectedUser != _selectedUser)
      return _paymentPageValidator.sink.add(true);

    _paymentPageValidator.sink.add(false);
  }

  void _checkIfBillPageIsValid() {
    // check bill amount and type are valid
    if (_billType != null && _billAmount != null && _billAmount > 0)
    // check from and to dates are not in wrong order
    if ((_fromDate == null || _toDate == null) ||
        _fromDate.isBefore(_toDate) ||
        _fromDate.isAtSameMomentAs(_toDate))
      return _billPageValidator.sink.add(true);

    _billPageValidator.sink.add(false);
  }

  Future<void> submitInfo() {
    if (!_submitted) {
      _submitted = true;
      if (_selectedOption is ShowBillSection) {
        if (_billAmount != null && _billType != null) {
          return _repo
              .createBill(
                  groupBloc.groupId,
                  Bill(
                      amount: _billAmount,
                      paidByUserId: groupBloc.isGroupOwner
                          ? _adminSelectedUser
                          : groupBloc.userId,
                      type: _billType,
                      notes: _billNotes,
                      createdAt: DateTime.now(),
                      fromDate: _fromDate,
                      toDate: _toDate))
              .then((_) => _repo.tabulateTotals(groupBloc.groupId));
        } else
          return Future.delayed(Duration(seconds: 0));
      } else if (_selectedOption is ShowPaymentSection) {
        if (_selectedUser != null && _billAmount != null) {
          return _repo
              .createPayment(
                  groupBloc.groupId,
                  Payment(
                      fromUserId: groupBloc.isGroupOwner
                          ? _adminSelectedUser
                          : groupBloc.userId,
                      toUserId: _selectedUser,
                      amount: _billAmount,
                      notes: _paymentNotes,
                      createdAt: DateTime.now()))
              .then((_) => _repo.tabulateTotals(groupBloc.groupId));
        }
      }
    }
    return Future.delayed(Duration(seconds: 0));
  }

  List<Widget> selectedEventDetails() {
    if (_selectedOption is ShowBillSection) {
      return <Widget>[
        _confirmText('Bill'),
        _adminSelectedUser != null
            ? _confirmText('Paid By: ${groupBloc.userName(_adminSelectedUser)}')
            : Container(),
        _confirmText('Amount: \$${_billAmount.toStringAsFixed(2)}'),
        _confirmText('Type: $_billType'),
        _confirmText('From: ${parseDateTime(_fromDate) ?? 'Current'}'),
        _confirmText('To: ${parseDateTime(_toDate) ?? 'Current'}'),
      ];
    } else {
      return <Widget>[
        _confirmText('Payment'),
        _confirmText('Amount: \$${_billAmount.toStringAsFixed(2)}'),
        _adminSelectedUser != null
            ? _confirmText('From: ${groupBloc.userName(_adminSelectedUser)}')
            : Container(),
        _confirmText('To: ${groupBloc.userName(_selectedUser)}'),
      ];
    }
  }

  Widget _confirmText(String text) {
    return Text(
      text,
      style: Style.regularTextStyle,
    );
  }

  @override
  void dispose() {
    _selectedUserController.close();
    _adminSelectedUserController.close();
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
    _adminModifyingFromUser.close();
  }
}

class BillOrPaymentSection {}

class ShowBillSection extends BillOrPaymentSection {}

class ShowPaymentSection extends BillOrPaymentSection {}
