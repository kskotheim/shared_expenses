import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/new_category_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/ui/group_page/categories/new_category_button.dart';

class BillCategoryList extends StatelessWidget {
  BillCategoryList();

  @override
  Widget build(BuildContext context) {
    GroupBloc groupBloc = BlocProvider.of<GroupBloc>(context);
    NewCategoryBloc newCategoryBloc = NewCategoryBloc(groupBloc: groupBloc);

    return BlocProvider(
      bloc: newCategoryBloc,
      child: Container(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Bill Categories for ${groupBloc.currentAccount.accountName}',
              style: Style.subTitleTextStyle,
            ),
            StreamBuilder<List<String>>(
                stream: newCategoryBloc.categoriesInGroupStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data.length == 0)
                    return ListTile(
                      title: Text('(no categories)'),
                    );

                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data
                        .map((type) => ListTile(
                              title: Text(type),
                              trailing: IconButton(
                                onPressed: () => groupBloc.deleteCategory(type),
                                icon: Icon(Icons.delete),
                              ),
                            ))
                        .toList(),
                  );
                }),
            NewCategoryButton(),
          ],
        ),
      ),
    );
  }
}
