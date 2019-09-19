import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';

class BillCategoryList extends StatelessWidget {
  final GroupBloc groupBloc;

  BillCategoryList({this.groupBloc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Bill Categories for ${groupBloc.currentAccount.accountName}',
            style: Style.titleTextStyle,
          ),
          ListView(
            shrinkWrap: true,
            children: (groupBloc.billTypes != null && groupBloc.billTypes.isNotEmpty) 
              ? groupBloc.billTypes
                .map((type) => ListTile(title: Text(type)))
                .toList() 
              : [ListTile(title: Text('(no categories)'),)],
          ),
        ],
      ),
    );
  }
}
