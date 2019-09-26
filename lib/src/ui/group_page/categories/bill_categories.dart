import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/new_category_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/ui/group_page/categories/new_category_button.dart';

class BillCategoryList extends StatelessWidget {
  final GroupBloc groupBloc;
  NewCategoryBloc _newCategoryBloc;

  BillCategoryList({this.groupBloc});

  @override
  Widget build(BuildContext context) {
    print('rebuilding bill category list');
    _newCategoryBloc = NewCategoryBloc(groupBloc: groupBloc);

    return BlocProvider(
      bloc: _newCategoryBloc,
      child: Container(
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
              children: (groupBloc.billTypes != null &&
                      groupBloc.billTypes.isNotEmpty)
                  ? groupBloc.billTypes
                      .map((type) => ListTile(
                            title: Text(type),
                            trailing: IconButton(
                              onPressed:() => groupBloc.deleteCategory(type),
                              icon: Icon(Icons.delete),
                            ),
                          ))
                      .toList()
                  : [
                      ListTile(
                        title: Text('(no categories)'),
                      )
                    ],
            ),
            NewCategoryButton(),
          ],
        ),
      ),
    );
  }
}
