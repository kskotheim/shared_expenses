import 'package:shared_expenses/src/res/db_strings.dart';

class Account {
  final String accountId;
  String accountName;

  Account({this.accountId, this.accountName}) : assert(accountId != null);

  Account.fromJson(Map<String, String> account) :
    accountId = account['accountId'],
    accountName = account[NAME];
}