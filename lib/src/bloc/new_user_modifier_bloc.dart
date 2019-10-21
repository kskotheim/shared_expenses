import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/event.dart';
import 'package:shared_expenses/src/res/models/user.dart';

class NewUserModifierBloc implements BlocBase {
  final GroupBloc groupBloc;
  final Repository _repo = Repository.getRepo;

  static String _selectedUser;
  static bool _allDatesSelected = true;
  static DateTime _fromDate;
  static DateTime _toDate;
  static num _shares;
  static bool _allCategoriesSelected = true;
  static Map<String, bool> _selectedCategories = {};

  static void resetVals() {
    _selectedUser = null;
    _fromDate = null;
    _toDate = null;
    _shares = null;
    _selectedCategories = {};
    _allDatesSelected = true;
    _allCategoriesSelected = true;
  }

  // checkboxes for which categories this modifier applies to
  List<CheckboxListTile> theCategoryCheckboxes;

  BehaviorSubject<String> _selectedUserController = BehaviorSubject<String>();
  Stream<String> get selectedUser =>
      _selectedUserController.stream.transform(_selectedUserTransformer);
  Function get selectUser => _selectedUserController.sink.add;

  StreamTransformer<String, String> _selectedUserTransformer =
      StreamTransformer<String, String>.fromHandlers(handleData: (data, sink) {
    _selectedUser = data;
    sink.add(data);
  });

  // controllers for the checkboxes that show or hide the date and category section
  BehaviorSubject<bool> _allDatesCheckboxController = BehaviorSubject<bool>();
  Stream<bool> get allDatesCheckbox =>
      _allDatesCheckboxController.stream.map((val) {
        _allDatesSelected = val;
        return val;
      });
  Function get setAllDatesCheckbox => _allDatesCheckboxController.sink.add;

  BehaviorSubject<bool> _allCategoriesCheckboxController =
      BehaviorSubject<bool>();
  Stream<bool> get allCategoriesCheckbox =>
      _allCategoriesCheckboxController.stream.map((val) {
        _allCategoriesSelected = val;
        return val;
      });
  Function get setAllCategoriesCheckbox =>
      _allCategoriesCheckboxController.sink.add;

  // Number of shares
  BehaviorSubject<String> _sharesController = BehaviorSubject<String>();
  Stream<num> get shares =>
      _sharesController.stream.transform(_sharesTransformer);
  Function get setShares => _sharesController.sink.add;

  StreamTransformer<String, num> _sharesTransformer =
      StreamTransformer<String, num>.fromHandlers(handleData: (data, sink) {
    if (data.length > 0) _shares = double.parse(data);
    else _shares = null;
    sink.add(_shares);
  });

  // Modifier from date
  BehaviorSubject<DateTime> _fromDateController = BehaviorSubject<DateTime>();
  Stream<DateTime> get fromDate =>
      _fromDateController.stream.transform(_fromDateTransformer);
  Function get newFromDate => _fromDateController.sink.add;

  // Modifier to date
  BehaviorSubject<DateTime> _toDateControlelr = BehaviorSubject<DateTime>();
  Stream<DateTime> get toDate =>
      _toDateControlelr.stream.transform(_toDateTransformer);
  Function get newToDate => _toDateControlelr.sink.add;

  StreamTransformer<DateTime, DateTime> _fromDateTransformer =
      StreamTransformer<DateTime, DateTime>.fromHandlers(
          handleData: (data, sink) {
    _fromDate = data;
    sink.add(data);
  });

  StreamTransformer<DateTime, DateTime> _toDateTransformer =
      StreamTransformer<DateTime, DateTime>.fromHandlers(
          handleData: (data, sink) {
    _toDate = data;
    sink.add(data);
  });

  // selected categories input stream
  BehaviorSubject<List<dynamic>> _selectCategoryController =
      BehaviorSubject<List<dynamic>>();
  Function get selectCategory => _selectCategoryController.sink.add;

  // selected categories output stream
  BehaviorSubject<Map<String, bool>> _selectedCategoriesController =
      BehaviorSubject<Map<String, bool>>();
  Stream<Map<String, bool>> get selectedCategoriesStream =>
      _selectedCategoriesController.stream;
  void _updateSelectedCategoriesStream() =>
      _selectedCategoriesController.sink.add(_selectedCategories);

  NewUserModifierBloc({this.groupBloc}) {
    assert(groupBloc != null);

    groupBloc.billTypes.forEach((type) => _selectedCategories[type] = false);

    _updateSelectedCategoriesStream();
    _selectCategoryController.stream.listen(_selectSpecificCategory);

    setAllCategoriesCheckbox(_allCategoriesSelected);
    setAllDatesCheckbox(_allDatesSelected);
  }

  void _selectSpecificCategory(List<dynamic> data) {
    _selectedCategories[data[0]] = data[1];
    _updateSelectedCategoriesStream();
  }

  Future<String> submitModifier() async {
    List<String> selectedCategories = [];
    if (!_allCategoriesSelected)
      _selectedCategories.forEach((key, val) {
        if (val) selectedCategories.add(key);
      });

    bool test1 = _selectedUser != null && _selectedUser.length > 0;
    bool test2 = _shares != null && _shares >= 0;

    bool test3 = (_allCategoriesSelected) ||
        (!_allCategoriesSelected && selectedCategories.length > 0);
    bool test4 = (_allDatesSelected) ||
        (_fromDate == null || _toDate == null || _fromDate.isBefore(_toDate));

    if (test1 && test2 && test3 && test4) {
      await _repo.createUserModifier(
        groupBloc.accountId,
        UserModifier(
            userId: _selectedUser,
            shares: _shares,
            fromDate: _fromDate,
            toDate: _toDate,
            categories: !_allCategoriesSelected ? selectedCategories : null),
      );
      await _repo.tabulateTotals(groupBloc.accountId, groupBloc.usersInAccount);
    }

    await Future.delayed(Duration(seconds: 0));
    return 'user passed: $test1, shares passed: $test2, categories passed: $test3, dates passed: $test4';
  }

  @override
  void dispose() {
    _selectedUserController.close();
    _sharesController.close();
    _toDateControlelr.close();
    _fromDateController.close();
    _allCategoriesCheckboxController.close();
    _allDatesCheckboxController.close();
    _selectCategoryController.close();
    _selectedCategoriesController.close();
  }
}
