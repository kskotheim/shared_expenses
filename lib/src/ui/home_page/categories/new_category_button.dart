import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/new_category_bloc.dart';

class NewCategoryButton extends StatelessWidget {

  NewCategoryBloc _newCategoryBloc = NewCategoryBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
          bloc: _newCategoryBloc,
          child: StreamBuilder<CategoryButtonState>(
              stream: _newCategoryBloc.categoryStream, //stream for button that processes events, including pressing 'new category' button, and submitting the new category
              builder: (context, snapshot){
                if(!snapshot.hasData || snapshot.data is ShowNewCategoryButton)
                  return IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _newCategoryBloc.newCategory, //add event to stream that triggers this turning into a text input
                  );
                if(snapshot.data is ShowNewCategoryForm)
                  return Text('enter the new category here ...');
                return Container();
              },
            ),
    );
          
  }
}