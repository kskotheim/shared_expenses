import 'dart:async';

import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/data/repository.dart';
import 'package:shared_expenses/src/res/models/event.dart';

class EditDeleteEventBloc implements BlocBase {
  final Repository repo = Repository.getRepo;
  final GroupBloc groupBloc;
  bool deleting = false;

  //Stream to handle which dialog page to show
  StreamController<StatusStreamType> _statusStreamController =
      StreamController<StatusStreamType>();
  Stream<StatusStreamType> get statusStream => _statusStreamController.stream;
  void initialized() => _statusStreamController.sink.add(StatusInitialized());
  void editBill(Bill bill) =>
      _statusStreamController.sink.add(StatusEditBill(bill));
  void editPayment(Payment payment) =>
      _statusStreamController.sink.add(StatusEditPayment(payment));
  void confirmDeleteBill(Bill bill) =>
      _statusStreamController.sink.add(StatusConfirmDeleteBill(bill));
  void confirmDeletePayment(Payment payment) =>
      _statusStreamController.sink.add(StatusConfirmDeletePayment(payment));

  //Stream to handle selecting between bill or payment
  StreamController<EditOptionSelected> _billOrPaymentSelectedController =
      StreamController<EditOptionSelected>();
  Stream<EditOptionSelected> get billOrPaymentSelected =>
      _billOrPaymentSelectedController.stream;
  void selectPayment() =>
      _billOrPaymentSelectedController.sink.add(ShowPayments());
  void selectBill() => _billOrPaymentSelectedController.sink.add(ShowBills());

  List<Bill> _bills;
  List<Payment> _payments;
  List<Bill> get theBills => _bills;
  List<Payment> get thePayments => _payments;

  EditDeleteEventBloc({this.groupBloc}) {
    _statusStreamController.sink.add(StatusUninitialized());
    _getBills();
    _getPayments();
  }

  Future<void> _getBills() async {
    _bills = await repo.billStream(groupBloc.accountId).first;
    _checkIfInitialized();
  }

  Future<void> _getPayments() async {
    _payments = await repo.paymentStream(groupBloc.accountId).first;
    _checkIfInitialized();
  }

  void _checkIfInitialized() {
    if (_bills != null && _payments != null) initialized();
  }

  Future<void> deleteBill(Bill bill) async {
    if (!deleting) {
      deleting = true;
      return Future.wait([
        repo.deleteBill(groupBloc.accountId, bill.billId),
        repo.createAccountEvent(
            groupBloc.accountId,
            AccountEvent(
                userId: groupBloc.userId,
                actionTaken: 'deleted \$${bill.amount.round()} ${bill.type} bill'))
      ]);
    }
  }

  Future<void> deletePayment(Payment payment) async {
    if (!deleting) {
      deleting = true;

      return Future.wait([
        repo.deletePayment(groupBloc.accountId, payment.paymentId),
        repo.createAccountEvent(
            groupBloc.accountId,
            AccountEvent(
                userId: groupBloc.userId,
                actionTaken:
                    'deleted \$${payment.amount.round()} payment by ${groupBloc.userName(payment.fromUserId)}'))
      ]);
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
