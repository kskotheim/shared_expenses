import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/new_category_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/ui/group_page/categories/new_category_button.dart';

class BillCategoryList extends StatelessWidget {
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
              'Bill Categories for ${groupBloc.currentGroup.accountName}',
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
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                        'Are you sure you want to delete this category?'),
                                    content: Text(
                                        'Any bills currently entered under this category will not be affected by new modifiers, even if you create a new category with the same name'),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('Cancel'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                      DeleteCategoryButton(deleteGroup: () async => groupBloc.deleteCategory(type),),
                                    ],
                                  ),
                                ),

                                //groupBloc.deleteCategory(type),
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

class DeleteCategoryButton extends StatefulWidget {
  final Function deleteGroup;

  DeleteCategoryButton({this.deleteGroup})
      : assert(deleteGroup != null);

  @override
  _DeleteCategoryButtonState createState() => _DeleteCategoryButtonState();
}

class _DeleteCategoryButtonState extends State<DeleteCategoryButton> {
  bool deleting = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(deleting ? 'Deleting ...' : 'Delete'),
      onPressed: !deleting ? () async {
        setState(() => deleting = true);
        await widget.deleteGroup();
        return Navigator.of(context).pop();
      } : null,
    );
  }
}
