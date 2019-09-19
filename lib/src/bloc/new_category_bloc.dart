import 'dart:async';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';



class NewCategoryBloc implements BlocBase {
  
  //input stream
  StreamController<CategoryButtonEvent> _categoryEventController = StreamController<CategoryButtonEvent>();
  void newCategory() => _categoryEventController.sink.add(NewCategoryButtonPushed());
  void submitCategory() => _categoryEventController.sink.add(NewCategorySubmitPushed());

  //output stream
  StreamController<CategoryButtonState> _categoryButtonController = StreamController<CategoryButtonState>();
  Stream<CategoryButtonState> get categoryStream => _categoryButtonController.stream;

  NewCategoryBloc(){
    _categoryButtonController.sink.add(ShowNewCategoryButton());
    _categoryEventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(CategoryButtonEvent event){
    if(event is NewCategoryButtonPushed){
      _categoryButtonController.sink.add(ShowNewCategoryForm());
    }
    if(event is NewCategorySubmitPushed){
      print('submitting category');
      //submit new category and then pop context
    }
  }
  
  
  @override
  void dispose() {
    _categoryEventController.close();
    _categoryButtonController.close();
  }

}



class CategoryButtonEvent {}

class NewCategoryButtonPushed extends CategoryButtonEvent {}

class NewCategorySubmitPushed extends CategoryButtonEvent {}


class CategoryButtonState {}

class ShowNewCategoryButton extends CategoryButtonState {}

class ShowNewCategoryForm extends CategoryButtonState {}