
import 'package:cloud_firestore/cloud_firestore.dart';

class Payment implements AnyEvent{
  String fromUserId;
  String toUserId;
  num amount;
  DateTime createdAt;

  Payment({this.fromUserId, this.toUserId, this.amount, this.createdAt}) :
    assert(fromUserId != null),
    assert(toUserId != null),
    assert(amount != null);

  Payment.fromJson(Map<String, dynamic> paymentRecord){
    fromUserId = paymentRecord['fromUserId']; 
    toUserId =paymentRecord['toUserId']; 
    amount = paymentRecord['amount'];
    createdAt = parseTime(paymentRecord['createdAt'].toDate());
  }

  Map<String, dynamic> toJson(){
    return {
      'fromUserId':fromUserId,
      'toUserId':toUserId,
      'amount':amount,
      'createdAt':createdAt
    };
  }
}

class Bill implements AnyEvent {
  String paidByUserId;
  String type;
  double amount;
  DateTime createdAt;

  Bill({this.paidByUserId, this.type, this.amount, this.createdAt}) : 
    assert(paidByUserId != null),
    assert(amount != null),
    assert(type != null);

  Bill.fromJson(Map<String, dynamic> billRecord){
    paidByUserId =billRecord['paidByUserId'];
    type =billRecord['type'];
    amount =billRecord['amount'];
    createdAt = parseTime(billRecord['createdAt']);
  }

  Map<String, dynamic> toJson(){
    return {
      'paidByUserId':paidByUserId,
      'type':type,
      'amount':amount,
      'createdAt':createdAt
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
