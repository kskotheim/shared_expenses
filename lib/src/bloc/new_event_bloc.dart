import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/payment.dart';

class NewEventBloc implements BlocBase {
  static const String BILL = 'Bill';
  static const String PAYMENT = 'Payment';

  final Repository repo = Repository();
  final GroupBloc groupBloc;
  List<DropdownMenuItem> userMenuItems;
  List<DropdownMenuItem> billTypeMenuItems;

  static String _optionSelected;
  static String _selectedUser;
  static String _selectedType;
  static double _billAmount;
  static DateTime _fromDate;
  static DateTime _toDate;

  StreamController<String> _optionSelectedController =
      StreamController<String>();
  Stream<String> get optionSelected =>
      _optionSelectedController.stream.transform(_optionSelectedTransformer);
  void selectPayment() => _optionSelectedController.sink.add(PAYMENT);
  void selectBill() => _optionSelectedController.sink.add(BILL);

  //Payment options:
  //User payment is to
  BehaviorSubject<String> _selectedUserController = BehaviorSubject<String>();
  Stream<String> get selectedUser =>
      _selectedUserController.stream.transform(_selectedUserTransformer);
  Function get selectUser => _selectedUserController.sink.add;

  //Amount
  BehaviorSubject<double> _billAmountController = BehaviorSubject<double>();
  Stream<double> get billAmount =>
      _billAmountController.stream.transform(_billAmountTransformer);
  void newBillAmount(String amt) =>
      _billAmountController.sink.add(double.parse(amt));

  //Bill options:
  //Bill type
  BehaviorSubject<String> _selectedTypeController = BehaviorSubject<String>();
  Stream<String> get selectedType =>
      _selectedTypeController.stream.transform(_selectedTypeTransformer);
  Function get selectType => _selectedTypeController.sink.add;

  //Amount
  //Same controller as above

  //Bill from date
  BehaviorSubject<DateTime> _fromDateController = BehaviorSubject<DateTime>();
  Stream<DateTime> get fromDate =>
      _fromDateController.stream.transform(_fromDateTransformer);
  Function get newFromDate => _fromDateController.sink.add;

  //Bill to date
  BehaviorSubject<DateTime> _toDateControlelr = BehaviorSubject<DateTime>();
  Stream<DateTime> get toDate =>
      _toDateControlelr.stream.transform(_toDateTransformer);
  Function get newToDate => _toDateControlelr.sink.add;

  NewEventBloc({this.groupBloc}) {
    userMenuItems = groupBloc.usersInAccount
        .map((user) => DropdownMenuItem(
              child: Text(user.userName),
              value: user.userId,
            ))
        .toList();

    billTypeMenuItems = (groupBloc.billTypes)
        .map((type) => DropdownMenuItem(
              child: Text(type),
              value: type,
            ))
        .toList();
  }

  final StreamTransformer<String, String> _optionSelectedTransformer =
      StreamTransformer<String, String>.fromHandlers(
          handleData: (selection, sink) {
    _optionSelected = selection;
    sink.add(selection);
  });

  final StreamTransformer<String, String> _selectedUserTransformer =
      StreamTransformer<String, String>.fromHandlers(handleData: (user, sink) {
    _selectedUser = user;
    sink.add(user);
  });
  final StreamTransformer<String, String> _selectedTypeTransformer =
      StreamTransformer<String, String>.fromHandlers(handleData: (type, sink) {
    _selectedType = type;
    sink.add(type);
  });
  final StreamTransformer<double, double> _billAmountTransformer =
      StreamTransformer<double, double>.fromHandlers(
          handleData: (billAmount, sink) {
    _billAmount = billAmount;
    sink.add(billAmount);
  });

  final StreamTransformer<DateTime, DateTime> _fromDateTransformer =
      StreamTransformer<DateTime, DateTime>.fromHandlers(
          handleData: (fromDate, sink) {
    _fromDate = fromDate;
    sink.add(fromDate);
  });
  final StreamTransformer<DateTime, DateTime> _toDateTransformer =
      StreamTransformer<DateTime, DateTime>.fromHandlers(
          handleData: (toDate, sink) {
    _toDate = toDate;
    sink.add(toDate);
  });

  Future<void> submitInfo() {
    if (_optionSelected == BILL) {
      if (_billAmount != null && _selectedType != null) {
        return repo
            .createBill(
                groupBloc.accountId,
                Bill(
                    amount: _billAmount,
                    paidByUserId: groupBloc.userId,
                    type: _selectedType,
                    createdAt: DateTime.now()))
            .then((_) =>
                repo.tabulateTotals(groupBloc.accountId, groupBloc.usersInAccount));
      } else
        return Future.delayed(Duration(seconds: 0));
    } else if (_optionSelected == PAYMENT) {
      if (_selectedUser != null && _billAmount != null) {
        return repo
            .createPayment(
                groupBloc.accountId,
                Payment(
                    fromUserId: groupBloc.userId,
                    toUserId: _selectedUser,
                    amount: _billAmount,
                    createdAt: DateTime.now()))
            .then((_) =>
                repo.tabulateTotals(groupBloc.accountId, groupBloc.usersInAccount));
      } else
        return Future.delayed(Duration(seconds: 0));
    } else
      return Future.delayed(Duration(seconds: 0));
  }

  @override
  void dispose() {
    _selectedUserController.close();
    _selectedTypeController.close();
    _billAmountController.close();
    _toDateControlelr.close();
    _fromDateController.close();
    _optionSelectedController.close();
  }

}
