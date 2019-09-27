import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/data/repository.dart';



class NewCategoryBloc implements BlocBase {
  
  final GroupBloc groupBloc;

  Repository repo = Repository.getRepo;
  
  //input stream
  StreamController<CategoryButtonEvent> _categoryEventController = StreamController<CategoryButtonEvent>();
  void newCategory() => _categoryEventController.sink.add(NewCategoryButtonPushed());
  void submitCategory() => _categoryEventController.sink.add(NewCategorySubmitPushed());

  //output stream
  StreamController<CategoryButtonState> _categoryButtonController = StreamController<CategoryButtonState>();
  Stream<CategoryButtonState> get categoryStream => _categoryButtonController.stream;
  void showNewCategoryForm() => _categoryButtonController.sink.add(ShowNewCategoryForm());
  void showNewCategoryButton() => _categoryButtonController.sink.add(ShowNewCategoryButton());

  //Stream for new category field
  BehaviorSubject<String> _newCategoryFieldController = BehaviorSubject<String>();
  Stream<String> get newCategoryField => _newCategoryFieldController.stream.transform(_saveCategoryText);
  void changeNewCategoryField(String newCategory) => _newCategoryFieldController.sink.add(newCategory);
  static String _newCategoryText = '';

  //Stream for the categories currently in the account
  StreamController<List<String>> _categoriesInGroupController = StreamController<List<String>>();
  Stream<List<String>> get categoriesInGroupStream => _categoriesInGroupController.stream;

  StreamSubscription _categoriesSubscription;


  NewCategoryBloc({this.groupBloc}){
    assert(groupBloc != null);
    _categoryEventController.stream.listen(_mapEventToState);
    _categoriesSubscription = repo.billTypeStream(groupBloc.accountId).listen(_addToCIGCSink);
  }

  void _addToCIGCSink(List<String> categories){
    _categoriesInGroupController.sink.add(categories);
  }

  void _mapEventToState(CategoryButtonEvent event){
    if(event is NewCategoryButtonPushed){
      showNewCategoryForm();
    }
    if(event is NewCategorySubmitPushed){
      _submitNewCategory();
    }
  }

  StreamTransformer _saveCategoryText = StreamTransformer<String, String>.fromHandlers(
    handleData: (string, sink){
      _newCategoryText  = string;
    }
  );

  Future<void> _submitNewCategory() async {
    List<String> billTypes = await repo.getBillTypes(groupBloc.accountId);

    if(!billTypes.contains(_newCategoryText)){   
      await repo.addBillType(groupBloc.accountId, _newCategoryText);
      await groupBloc.getCategories();
      return showNewCategoryButton();
    } 
    else return null;
  }
  
  
  @override
  void dispose() {
    _categoryEventController.close();
    _categoryButtonController.close();
    _newCategoryFieldController.close();
    _categoriesInGroupController.close();
    _categoriesSubscription.cancel();
  }

}



class CategoryButtonEvent {}

class NewCategoryButtonPushed extends CategoryButtonEvent {}

class NewCategorySubmitPushed extends CategoryButtonEvent {}


class CategoryButtonState {}

class ShowNewCategoryButton extends CategoryButtonState {}

class ShowNewCategoryForm extends CategoryButtonState {}