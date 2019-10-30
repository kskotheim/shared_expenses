import 'package:cloud_firestore/cloud_firestore.dart';

class Payment implements AnyEvent {
  String fromUserId;
  String toUserId;
  num amount;
  DateTime createdAt;
  String notes;

  Payment(
      {this.fromUserId,
      this.toUserId,
      this.amount,
      this.createdAt,
      this.notes}) {
    assert(fromUserId != null);
    assert(toUserId != null);
    assert(amount != null);
    if (createdAt == null) createdAt = DateTime.now();
    if (notes == null) notes = '';
  }

  Payment.fromJson(Map<String, dynamic> paymentRecord) {
    fromUserId = paymentRecord['fromUserId'];
    toUserId = paymentRecord['toUserId'];
    amount = paymentRecord['amount'];
    createdAt = parseTime(paymentRecord['createdAt'].toDate());
    notes = paymentRecord['notes'];
  }

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'amount': amount,
      'createdAt': createdAt,
      'notes': notes,
    };
  }
}

class Bill implements AnyEvent {
  String paidByUserId;
  String type;
  double amount;
  String notes;
  DateTime createdAt;
  DateTime fromDate;
  DateTime toDate;

  // this method splits one bill into multiple according to a list of DateTimes.
  // it is used for calculating bill totals by scaling portions of bills according to
  // user modifier dates
  static List<Bill> splitBill(Bill bill, List<DateTime> splitDates){
    List<Bill> theBills = [];
    for(int i=0; i<splitDates.length; i++){
      if(theBills.isEmpty){
        theBills.addAll(_splitBill(bill, splitDates[i]));
      }
      else {
        Bill billToSplit;
        theBills.forEach((bill) {
          if(bill.fromDate.isBefore(splitDates[i]) && bill.toDate.isAfter(splitDates[i])) billToSplit = bill;
        });
        theBills.remove(billToSplit);
        theBills.addAll(_splitBill(billToSplit, splitDates[i]));
      }
    }
    return theBills;
  }

  static List<Bill> _splitBill(Bill bill, DateTime splitDate) {
    if (splitDate.isAfter(bill.fromDate) && splitDate.isBefore(bill.toDate)) {
      List<Bill> returnBills = [];
      double firstBillProportion = (splitDate.millisecondsSinceEpoch -
              bill.fromDate.millisecondsSinceEpoch) /
          (bill.toDate.millisecondsSinceEpoch -
              bill.fromDate.millisecondsSinceEpoch);

      returnBills.add(
        Bill(
          fromDate: bill.fromDate,
          toDate: splitDate,
          amount: firstBillProportion * bill.amount,
          type: bill.type,
          paidByUserId: bill.paidByUserId,
        ),
      );
      returnBills.add(
        Bill(
          fromDate: splitDate,
          toDate: bill.toDate,
          amount: (1 - firstBillProportion) * bill.amount,
          type: bill.type,
          paidByUserId: bill.paidByUserId,
        ),
      );
      return returnBills;
    } else
      return [bill];
  }

  Bill(
      {this.paidByUserId,
      this.type,
      this.amount,
      this.notes,
      this.createdAt,
      this.toDate,
      this.fromDate}) {
    assert(paidByUserId != null);
    assert(amount != null);
    assert(type != null);
    if (createdAt == null) createdAt = DateTime.now();
    if (toDate == null) toDate = createdAt;
    if (fromDate == null) fromDate = createdAt;
    if (notes == null) notes = '';
  }

  Bill.fromJson(Map<String, dynamic> billRecord) {
    paidByUserId = billRecord['paidByUserId'];
    type = billRecord['type'];
    amount = billRecord['amount'];
    createdAt = parseTime(billRecord['createdAt']);
    fromDate = parseTime(billRecord['fromDate'] ?? createdAt);
    toDate = parseTime(billRecord['toDate'] ?? createdAt);
    notes = billRecord['notes'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'paidByUserId': paidByUserId,
      'type': type,
      'amount': amount,
      'notes': notes,
      'createdAt': createdAt,
      'fromDate': fromDate,
      'toDate': toDate
    };
  }
}

class AccountEvent implements AnyEvent {
  DateTime createdAt;
  String userId;
  String actionTaken; // added to account, edited bill / category, changed name
  String secondaryString;

  AccountEvent({this.createdAt, this.userId, this.actionTaken, this.secondaryString}) {
    assert(userId != null);
    assert(actionTaken != null);

    createdAt = DateTime.now();
  }

  AccountEvent.fromJson(Map<String, dynamic> json) {
    createdAt = parseTime(json['createdAt']);
    userId = json['userId'];
    actionTaken = json['actionTaken'];
    secondaryString = json['secondaryString'];
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'userId': userId,
      'actionTaken': actionTaken,
      'secondaryString': secondaryString
    };
  }
}

abstract class AnyEvent {
  DateTime createdAt;
  Map<String, dynamic> toJson();
}

DateTime parseTime(dynamic date) {
  assert(date is Timestamp || date is DateTime);
  return (date is Timestamp) ? date.toDate() : (date as DateTime);
}
