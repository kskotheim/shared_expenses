

class Payment extends AnyEvent{
  String fromUserId;
  String toUserId;
  double amount;

  Payment({this.fromUserId, this.toUserId, this.amount}){
    assert(fromUserId != null);
    assert(toUserId != null);
    assert(amount != null);
  }

  Payment.fromJson(Map<String, dynamic> paymentRecord){
    fromUserId = paymentRecord['fromUserId']; 
    toUserId =paymentRecord['toUserId']; 
    amount = paymentRecord['amount'];
  }

  Map<String, dynamic> toJson(){
    return {
      'fromUserId':fromUserId,
      'toUserId':toUserId,
      'amount':amount
    };
  }

  String get name => '$fromUserId paid $toUserId \$${amount.round()}';
}



class AnyEvent {
  final String name;
  AnyEvent({this.name});
}

