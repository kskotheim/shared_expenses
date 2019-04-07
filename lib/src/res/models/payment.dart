

class Payment implements AnyEvent{
  String fromUserId;
  String toUserId;
  double amount;
  DateTime createdAt;

  Payment({this.fromUserId, this.toUserId, this.amount, this.createdAt}) :
    assert(fromUserId != null),
    assert(toUserId != null),
    assert(amount != null);

  Payment.fromJson(Map<String, dynamic> paymentRecord){
    fromUserId = paymentRecord['fromUserId']; 
    toUserId =paymentRecord['toUserId']; 
    amount = paymentRecord['amount'];
    createdAt =paymentRecord['createdAt'].toDate();
  }

  Map<String, dynamic> toJson(){
    return {
      'fromUserId':fromUserId,
      'toUserId':toUserId,
      'amount':amount,
      'createdAt':createdAt
    };
  }

  String get name => '$fromUserId paid $toUserId \$${amount.round()}';
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
    createdAt =billRecord['createdAt'].toDate();
  }

  Map<String, dynamic> toJson(){
    return {
      'paidByUserId':paidByUserId,
      'type':type,
      'amount':amount,
      'createdAt':createdAt
    };
  }

  String get name => '$paidByUserId paid \$$amount $type bill';

}

abstract class AnyEvent {
  DateTime createdAt;
  String get name;
  Map<String, dynamic> toJson();

}

