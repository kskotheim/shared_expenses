import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/event.dart';
import 'package:shared_expenses/src/res/models/user.dart';
import 'package:shared_expenses/src/res/util.dart';

class NewUserModifierBloc implements BlocBase {
  final GroupBloc groupBloc;
  final Repository _repo = Repository.getRepo;

  String _selectedUser;
  DateTime _fromDate;
  DateTime _toDate;
  num _shares;
  ModifierDialogPageToShow _pageToShow = ModifierDialogMain();
  Map<String, bool> _selectedCategories = {};
  bool _submitted = false;

  String get getCategoriesString => _selectedCategories.isEmpty
      ? 'All Categories'
      : !_selectedCategories.values.reduce((a, b) => a || b)
          ? 'All Categories'
          : _selectedCategories.keys
              .where((key) => _selectedCategories[key])
              .join(', ');

  String get getDatesString => (_fromDate == null && _toDate == null)
      ? 'All Dates'
      : _fromDate == null
          ? 'Beginning to ${parseDateTime(_toDate)}'
          : _toDate == null
              ? '${parseDateTime(_fromDate)} to End'
              : '${parseDateTime(_fromDate)} to ${parseDateTime(_toDate)}';

  void resetVals() {
    _selectedUser = null;
    _fromDate = null;
    _toDate = null;
    _shares = null;
    _selectedCategories = {};
    _pageToShow = ModifierDialogMain();
  }

  // checkboxes for which categories this modifier applies to
  List<CheckboxListTile> theCategoryCheckboxes;

  BehaviorSubject<String> _selectedUserController = BehaviorSubject<String>();
  Stream<String> get selectedUser =>
      _selectedUserController.stream.map(_saveSelectedUser);
  Function get selectUser => _selectedUserController.sink.add;

  String _saveSelectedUser(String user) {
    _selectedUser = user;
    _validateModifier();
    return user;
  }

  BehaviorSubject<ModifierDialogPageToShow> _pageToShowController =
      BehaviorSubject<ModifierDialogPageToShow>();
  Stream<ModifierDialogPageToShow> get modifierDialogPageToShow =>
      _pageToShowController.stream;
  void showMainPage([bool _]) =>
      _pageToShowController.sink.add(ModifierDialogMain());
  void showDatesPage([bool _]) =>
      _pageToShowController.sink.add(ModifierDialogDates());
  void showCategories([bool _]) =>
      _pageToShowController.sink.add(ModifierDialogCategories());

  // Number of shares
  BehaviorSubject<String> _sharesController = BehaviorSubject<String>();
  Stream<num> get shares => _sharesController.stream.map(_saveShares);
  Function get setShares => _sharesController.sink.add;

  num _saveShares(String shares) {
    if (shares.length > 0)
      _shares = double.parse(shares);
    else
      _shares = null;
    _validateModifier();
    return _shares;
  }

  // Modifier from date
  BehaviorSubject<DateTime> _fromDateController = BehaviorSubject<DateTime>();
  Stream<DateTime> get fromDate =>
      _fromDateController.stream.map(_saveFromDate);
  Function get newFromDate => _fromDateController.sink.add;

  DateTime _saveFromDate(DateTime date) {
    _fromDate = date;
    return date;
  }

  // Modifier to date
  BehaviorSubject<DateTime> _toDateControlelr = BehaviorSubject<DateTime>();
  Stream<DateTime> get toDate => _toDateControlelr.stream.map(_saveToDate);
  Function get newToDate => _toDateControlelr.sink.add;

  DateTime _saveToDate(DateTime date) {
    _toDate = date;
    return date;
  }

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

  BehaviorSubject<bool> _modifierValidatorController = BehaviorSubject<bool>();
  Stream<bool> get modifierValidated => _modifierValidatorController.stream;
  void _validateModifier() {
    if (_selectedUser != null && _shares != null) {
      _modifierValidatorController.sink.add(true);
    } else {
      _modifierValidatorController.sink.add(false);
    }
  }

  NewUserModifierBloc({this.groupBloc}) {
    assert(groupBloc != null);
    print('building new user modifier bloc');
    groupBloc.billTypes.forEach((type) => _selectedCategories[type] = false);

    _updateSelectedCategoriesStream();
    _selectCategoryController.stream.listen(_selectSpecificCategory);
  }

  void _selectSpecificCategory(List<dynamic> data) {
    _selectedCategories[data[0]] = data[1];
    _updateSelectedCategoriesStream();
  }

  Future<String> submitModifier() async {
    if (!_submitted) {
      _submitted = true;
      List<String> selectedCategories = [];
      _selectedCategories.forEach((key, val) {
        if (val) selectedCategories.add(key);
      });

      bool test1 = _selectedUser != null && _selectedUser.length > 0;
      bool test2 = _shares != null && _shares >= 0;

      bool test4 =
          (_fromDate == null || _toDate == null || _fromDate.isBefore(_toDate));

      if (test1 && test2 && test4) {
        await _repo.createUserModifier(
          groupBloc.accountId,
          UserModifier(
              userId: _selectedUser,
              shares: _shares,
              fromDate: _fromDate,
              toDate: _toDate,
              categories:
                  selectedCategories.isNotEmpty ? selectedCategories : null,
              // user # of shares (categories) from -> to
              description:
                  '${groupBloc.userName(_selectedUser)} $_shares shares ${selectedCategories.isNotEmpty ? selectedCategories.join(', ') : ''} ${_fromDate != null ? parseDateTime(_fromDate) : 'Beginning'} to ${_toDate != null ? parseDateTime(_toDate) : 'End'}'),
        );
        await _repo.tabulateTotals(
            groupBloc.accountId, groupBloc.usersInAccount);
      }
    }
    return Future.delayed(Duration(seconds: 0));
  }

  @override
  void dispose() {
    _selectedUserController.close();
    _sharesController.close();
    _toDateControlelr.close();
    _fromDateController.close();
    _pageToShowController.close();
    _modifierValidatorController.close();
    _selectCategoryController.close();
    _selectedCategoriesController.close();
  }
}

class ModifierDialogPageToShow {}

class ModifierDialogMain extends ModifierDialogPageToShow {}

class ModifierDialogDates extends ModifierDialogPageToShow {}

class ModifierDialogCategories extends ModifierDialogPageToShow {}
