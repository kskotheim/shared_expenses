import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/edit_event_bloc.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/event.dart';

// This class manages the dialog that a user uses to select which bill or payment to edit or delete. 
// It also has methods to interface with the repository and handle the updating and deleting of bills or expenses

class EditDeleteDialogBloc implements BlocBase {
  final Repository repo = Repository.getRepo;
  final GroupBloc groupBloc;
  bool submitted = false;

  EditEventBloc editEventBloc;

  //Stream to handle which dialog page to show
  BehaviorSubject<StatusStreamType> _statusStreamController =
      BehaviorSubject<StatusStreamType>.seeded(StatusUninitialized());
  Stream<StatusStreamType> get statusStream => _statusStreamController.stream;
  void initialized() => _statusStreamController.sink.add(StatusInitialized());

  void editBill(Bill bill) {
    editEventBloc.setEvent(bill);
    return _statusStreamController.sink.add(StatusEditBill(bill));
  }

  void editPayment(Payment payment) {
    editEventBloc.setEvent(payment);
    return _statusStreamController.sink.add(StatusEditPayment(payment));
  }

  void confirmDeleteBill(Bill bill) =>
      _statusStreamController.sink.add(StatusConfirmDeleteBill(bill));
  void confirmDeletePayment(Payment payment) =>
      _statusStreamController.sink.add(StatusConfirmDeletePayment(payment));
  void confirmUpdateBill(Bill bill) =>
      _statusStreamController.sink.add(StatusConfirmUpdateBill(bill));
  void confirmUpdatePayment(Payment payment) =>
      _statusStreamController.sink.add(StatusConfirmUpdatePayment(payment));

  //Stream to handle selecting between bill or payment
  PublishSubject<EditOptionSelected> _billOrPaymentSelectedController =
      PublishSubject<EditOptionSelected>();
  Stream<EditOptionSelected> get billOrPaymentSelected =>
      _billOrPaymentSelectedController.stream;
  void selectPayment() =>
      _billOrPaymentSelectedController.sink.add(ShowPayments());
  void selectBill() => _billOrPaymentSelectedController.sink.add(ShowBills());

  List<Bill> _bills;
  List<Payment> _payments;
  List<Bill> get theBills => _bills;
  List<Payment> get thePayments => _payments;

  EditDeleteDialogBloc({this.groupBloc}) {
    assert(groupBloc != null);
    _getBills();
    _getPayments();
    editEventBloc = EditEventBloc(groupBloc: groupBloc);
  }

  Future<void> _getBills() async {
    _bills = await repo.billStream(groupBloc.groupId).first;
    _checkIfInitialized();
  }

  Future<void> _getPayments() async {
    _payments = await repo.paymentStream(groupBloc.groupId).first;
    _checkIfInitialized();
  }

  void _checkIfInitialized() {
    if (_bills != null && _payments != null) initialized();
  }

  Future<void> deleteBill(Bill bill) async {
    if (!submitted) {
      submitted = true;
      await Future.wait([
        repo.deleteBill(groupBloc.groupId, bill.billId),
        repo.createAccountEvent(
            groupBloc.groupId,
            AccountEvent(
                userId: groupBloc.userId,
                actionTaken:
                    'deleted \$${bill.amount.round()} ${bill.type} bill'))
      ]);
      return repo.tabulateTotals(groupBloc.groupId);
    }
  }

  Future<void> deletePayment(Payment payment) async {
    if (!submitted) {
      submitted = true;

      await Future.wait([
        repo.deletePayment(groupBloc.groupId, payment.paymentId),
        repo.createAccountEvent(
            groupBloc.groupId,
            AccountEvent(
                userId: groupBloc.userId,
                actionTaken:
                    'deleted \$${payment.amount.round()} payment by ${groupBloc.userName(payment.fromUserId)}'))
      ]);
      return repo.tabulateTotals(groupBloc.groupId);
    }
  }

  Future<void> updateBill(Bill newBill) async {
    if (!submitted) {
      submitted = true;

      await Future.wait([
        repo.updateBill(groupBloc.groupId, newBill.billId, newBill.toJson()),
        repo.createAccountEvent(
            groupBloc.groupId,
            AccountEvent(
                userId: groupBloc.userId,
                actionTaken:
                    'updated \$${newBill.amount} ${newBill.type} bill'))
      ]);
      return repo.tabulateTotals(groupBloc.groupId);
    }
  }

  Future<void> updatePayment(Payment newPayment) async {
    if (!submitted) {
      submitted = true;

      await Future.wait([
        repo.updatePayment(
            groupBloc.groupId, newPayment.paymentId, newPayment.toJson()),
        repo.createAccountEvent(
            groupBloc.groupId,
            AccountEvent(
                userId: groupBloc.userId,
                actionTaken:
                    'updated \$${newPayment.amount} payment from ${groupBloc.userName(newPayment.fromUserId)} to ${groupBloc.userName(newPayment.toUserId)}')),
      ]);
      return repo.tabulateTotals(groupBloc.groupId);
    }
  }

  @override
  void dispose() {
    _billOrPaymentSelectedController.close();
    _statusStreamController.close();
  }
}

class EditOptionSelected {}

class ShowBills extends EditOptionSelected {}

class ShowPayments extends EditOptionSelected {}

// status stream types
class StatusStreamType {}

class StatusUninitialized extends StatusStreamType {}

class StatusInitialized extends StatusStreamType {}

class StatusEditPayment extends StatusStreamType {
  final Payment payment;
  StatusEditPayment(this.payment);
}

class StatusEditBill extends StatusStreamType {
  final Bill bill;
  StatusEditBill(this.bill);
}

class StatusConfirmDeletePayment extends StatusStreamType {
  final Payment payment;
  StatusConfirmDeletePayment(this.payment);
}

class StatusConfirmDeleteBill extends StatusStreamType {
  final Bill bill;
  StatusConfirmDeleteBill(this.bill);
}

class StatusConfirmUpdatePayment extends StatusStreamType {
  final Payment payment;
  StatusConfirmUpdatePayment(this.payment);
}

class StatusConfirmUpdateBill extends StatusStreamType {
  final Bill bill;
  StatusConfirmUpdateBill(this.bill);
}
