import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/new_category_bloc.dart';

class NewCategoryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NewCategoryBloc newCategoryBloc = BlocProvider.of<NewCategoryBloc>(context);

    return StreamBuilder<CategoryButtonState>(
      stream: newCategoryBloc
          .categoryStream, //stream for button that processes events, including pressing 'new category' button, and submitting the new category
      builder: (newContext, snapshot) {
        if (!snapshot.hasData || snapshot.data is ShowNewCategoryButton)
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: newCategoryBloc
                    .newCategory, //add event to stream that triggers this turning into a text input
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.check),
              ),
            ],
          );
        if (snapshot.data is ShowNewCategoryForm) {
          //return text field
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: newCategoryBloc.showNewCategoryButton,
              ),
              Container(
                  width: 100.0,
                  child: StreamBuilder<String>(
                      stream: newCategoryBloc.newCategoryField,
                      builder: (context, snapshot) {
                        return TextField(
                          keyboardType: TextInputType.text,
                          onChanged: newCategoryBloc.changeNewCategoryField,
                          decoration:
                              InputDecoration(errorText: snapshot.error),
                        );
                      })),
              FlatButton(
                child: Text('Submit'),
                onPressed: () => newCategoryBloc.submitCategory(),
              )
            ],
          );
        }
        return Container();
      },
    );
  }
}
